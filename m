Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0C646B0377
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 12:48:45 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id j9-v6so13034487pfn.20
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 09:48:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13-v6sor13040278pfc.26.2018.11.06.09.48.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 09:48:44 -0800 (PST)
Message-ID: <1541526521.196084.184.camel@acm.org>
Subject: Re: [PATCH] slab.h: Avoid using & for logical and of booleans
From: Bart Van Assche <bvanassche@acm.org>
Date: Tue, 06 Nov 2018 09:48:41 -0800
In-Reply-To: <CAKgT0UekDV4euPHs-wrZixGN1ryhZBq_42XdK6BapYke_xomJg@mail.gmail.com>
References: <20181105204000.129023-1-bvanassche@acm.org>
	 <20181105131305.574d85469f08a4b76592feb6@linux-foundation.org>
	 <1541454489.196084.157.camel@acm.org>
	 <ce6faf63-1661-abe5-16a6-8c19cc9f6689@rasmusvillemoes.dk>
	 <1541457654.196084.159.camel@acm.org>
	 <CAKgT0Udci4Ai4OD20NSRuDckE_G4RHma3Bg6H1Um6N9Se_zPew@mail.gmail.com>
	 <1541462466.196084.163.camel@acm.org>
	 <CAKgT0Ue59US_f-cZtoA=yVbFJ03ca5OMce2opUdQcsvgd8LWMw@mail.gmail.com>
	 <1541464370.196084.166.camel@acm.org>
	 <CAKgT0UekDV4euPHs-wrZixGN1ryhZBq_42XdK6BapYke_xomJg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-7"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux@rasmusvillemoes.dk, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, guro@fb.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm <linux-mm@kvack.org>

On Tue, 2018-11-06 at 09:20 -0800, Alexander Duyck wrote:
+AD4 On Mon, Nov 5, 2018 at 4:32 PM Bart Van Assche +ADw-bvanassche+AEA-acm.org+AD4 wrote:
+AD4 +AD4 
+AD4 +AD4 On Mon, 2018-11-05 at 16:11 -0800, Alexander Duyck wrote:
+AD4 +AD4 +AD4 If we really don't care then why even bother with the switch statement
+AD4 +AD4 +AD4 anyway? It seems like you could just do one ternary operator and be
+AD4 +AD4 +AD4 done with it. Basically all you need is:
+AD4 +AD4 +AD4 return (defined(CONFIG+AF8-ZONE+AF8-DMA) +ACYAJg (flags +ACY +AF8AXw-GFP+AF8-DMA)) ? KMALLOC+AF8-DMA :
+AD4 +AD4 +AD4         (flags +ACY +AF8AXw-GFP+AF8-RECLAIMABLE) ? KMALLOC+AF8-RECLAIM : 0+ADs
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 Why bother with all the extra complexity of the switch statement?
+AD4 +AD4 
+AD4 +AD4 I don't think that defined() can be used in a C expression. Hence the
+AD4 +AD4 IS+AF8-ENABLED() macro. If you fix that, leave out four superfluous parentheses,
+AD4 +AD4 test your patch, post that patch and cc me then I will add my Reviewed-by.
+AD4 
+AD4 Actually the defined macro is used multiple spots in if statements
+AD4 throughout the kernel.

The only 'if (defined(' matches I found in the kernel tree that are not
preprocessor statements occur in Perl code. Maybe I overlooked something?

+AD4 The reason for IS+AF8-ENABLED is to address the fact that we can be
+AD4 dealing with macros that indicate if they are built in or a module
+AD4 since those end up being two different defines depending on if you
+AD4 select 'y' or 'm'.

>From Documentation/process/coding-style.rst:

Within code, where possible, use the IS+AF8-ENABLED macro to convert a Kconfig
symbol into a C boolean expression, and use it in a normal C conditional:

.. code-block:: c

	if (IS+AF8-ENABLED(CONFIG+AF8-SOMETHING)) +AHs
		...
	+AH0

Bart.
