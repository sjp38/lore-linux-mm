Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5A496B0313
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:37:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j28so93466905pfk.14
        for <linux-mm@kvack.org>; Tue, 30 May 2017 05:37:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v8si13500494pgb.49.2017.05.30.05.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 05:37:31 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4UCYst1117003
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:37:30 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2as8utg2pc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:37:30 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 30 May 2017 13:37:28 +0100
Date: Tue, 30 May 2017 14:37:24 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next] memory hotplug regression
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170530121806.GD7969@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530121806.GD7969@dhcp22.suse.cz>
Message-Id: <20170530123724.GC4874@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 30, 2017 at 02:18:06PM +0200, Michal Hocko wrote:
> > So ZONE_DMA ends within ZONE_NORMAL. This shouldn't be possible, unless
> > this restriction is gone?
> 
> The patch below should help.

It does fix this specific problem, but introduces a new one:

# echo online_movable > /sys/devices/system/memory/memory16/state
# cat /sys/devices/system/memory/memory16/valid_zones
Movable
# echo offline > /sys/devices/system/memory/memory16/state
# cat /sys/devices/system/memory/memory16/valid_zones
          <--- no output

Memory block 16 is the only one I onlined and offlineto ZONE_MOVABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
