Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5535D6B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 19:05:25 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1232741pzk.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 16:05:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=yXq_avxZPRrhfw55kadeZRH-aaw@mail.gmail.com>
References: <BANLkTimo=yXTrgjQHn9746oNdj97Fb-Y9Q@mail.gmail.com>
	<20110518144129.GB4296@dumpdata.com>
	<BANLkTikxzEb7UkUfxmdHhHMc04P4bmKGXQ@mail.gmail.com>
	<20110518154055.GA7037@dumpdata.com>
	<BANLkTi=yXq_avxZPRrhfw55kadeZRH-aaw@mail.gmail.com>
Date: Thu, 19 May 2011 00:59:18 +0200
Message-ID: <BANLkTimago0y4VF3q_f=gUSRRkw1wxYbpA@mail.gmail.com>
Subject: Re: driver mmap implementation for memory allocated with pci_alloc_consistent()?
From: Leon Woestenberg <leon.woestenberg@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pci@vger.kernel.org, linux-mm@kvack.org

Hello,

On Wed, May 18, 2011 at 9:35 PM, Leon Woestenberg
<leon.woestenberg@gmail.com> wrote:
> On Wed, May 18, 2011 at 5:40 PM, Konrad Rzeszutek Wilk
>>> > On Wed, May 18, 2011 at 03:02:30PM +0200, Leon Woestenberg wrote:
>>> >>
>>> >> What is the correct implementation of the driver mmap (file operation
>>> >> method) for such memory?
>>> >

I have written an implementation based on vm_insert_pfn() and friends,
and posted the code in a new thread.

It doesn't work yet but I hope some of you kernel experts can look along.

Regards,
-- 
Leon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
