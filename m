Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 90E656B0005
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 06:51:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so108442833wme.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 03:51:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l1si3513327wjy.118.2016.07.06.03.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 03:51:19 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u66AiKnu130603
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 06:51:18 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 240ndntfc0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Jul 2016 06:51:17 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 Jul 2016 11:51:16 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id B2A5E1B08067
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 11:52:31 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u66ApDYq16777494
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 10:51:13 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u66ApDgQ015462
	for <linux-mm@kvack.org>; Wed, 6 Jul 2016 06:51:13 -0400
Date: Wed, 6 Jul 2016 12:51:12 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page
 table entries
In-Reply-To: <015d01d1d768$6db5d9e0$49218da0$@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>
	<014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>
	<20160706082350.5c56ca40@mschwide>
	<015301d1d751$8973de50$9c5b9af0$@alibaba-inc.com>
	<20160706104753.74daeaa2@mschwide>
	<015d01d1d768$6db5d9e0$49218da0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20160706125112.6cdf8262@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 06 Jul 2016 17:26:08 +0800
"Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:

> > 
> > You are still a bit cryptic, 
> >
> Sorry, Sir, simply because I'm not native English speaker.
> 
> > are you trying to tell me that your hint is
> > about trying to avoid the preempt_enable() call?
> > 
> Yes, since we are already in the context with page table lock held.

Ok, got it. An option would be to drop the preempt_disable/preempt_enable,
add "BUG_ON(preemptible())" and use raw_smp_processor_id. But I wonder if
it is worth the effort.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
