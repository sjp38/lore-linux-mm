Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6E56B0036
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:50:43 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id g15so654099eak.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:50:42 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id d46si15511852eeo.18.2014.01.16.07.50.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 07:50:37 -0800 (PST)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Thu, 16 Jan 2014 15:50:37 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id ABBD01B0806B
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:49:57 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0GFoMeX62062664
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:50:22 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0GFoYZ0028633
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:50:34 -0700
Date: Thu, 16 Jan 2014 16:50:32 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V4 0/2] mm/memblock: Excluded memory
Message-ID: <20140116165032.1730c040@lilie>
In-Reply-To: <1389878827-7827-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389878827-7827-1-git-send-email-phacht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, tangchen@cn.fujitsu.com, zhangyanfei@cn.fujitsu.com, yinghai@kernel.org, grygorii.strashko@ti.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Patch fits Andrew's linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
