Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 361AC6B4872
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:36:49 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so23912361plk.12
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:36:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id be11si3822872plb.134.2018.11.27.06.36.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 06:36:47 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAREY3hH104120
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:36:47 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p17j30ugf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:36:47 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Nov 2018 14:36:44 -0000
Date: Tue, 27 Nov 2018 15:36:38 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: warn only once if page table misaccounting is
 detected
References: <20181127083603.39041-1-heiko.carstens@de.ibm.com>
 <20181127131916.GX12455@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20181127131916.GX12455@dhcp22.suse.cz>
Message-Id: <20181127143638.GE3625@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill@shutemov.name>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Nov 27, 2018 at 02:19:16PM +0100, Michal Hocko wrote:
> On Tue 27-11-18 09:36:03, Heiko Carstens wrote:
> > Use pr_alert_once() instead of pr_alert() if page table misaccounting
> > has been detected.
> > 
> > If this happens once it is very likely that there will be numerous
> > other occurrence as well, which would flood dmesg and the console with
> > hardly any added information. Therefore print the warning only once.
> 
> Have you actually experience a flood of these messages? Is one per mm
> message really that much?

Yes, I did. Since in this case all compat processes caused the message
to appear, I saw thousands of these messages.

> If yes why rss counters do not exhibit the same problem?

No rss counter messages appeared. Or do you suggest that the other
pr_alert() within check_mm() should also be changed?
