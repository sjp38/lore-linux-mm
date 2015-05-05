Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 581176B0032
	for <linux-mm@kvack.org>; Tue,  5 May 2015 16:25:57 -0400 (EDT)
Received: by oign205 with SMTP id n205so157577327oig.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 13:25:57 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id cg7si10800838obc.97.2015.05.05.13.25.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 13:25:56 -0700 (PDT)
Message-ID: <1430856408.23761.291.camel@misato.fc.hp.com>
Subject: Re: [PATCH v4 2/7] mtrr, x86: Fix MTRR lookup to handle inclusive
 entry
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 05 May 2015 14:06:48 -0600
In-Reply-To: <20150505200931.GS3910@pd.tnic>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
	 <1427234921-19737-3-git-send-email-toshi.kani@hp.com>
	 <20150505171114.GM3910@pd.tnic>
	 <1430847128.23761.276.camel@misato.fc.hp.com>
	 <20150505183947.GO3910@pd.tnic>
	 <1430854292.23761.284.camel@misato.fc.hp.com>
	 <20150505200931.GS3910@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 2015-05-05 at 22:09 +0200, Borislav Petkov wrote:
> On Tue, May 05, 2015 at 01:31:32PM -0600, Toshi Kani wrote:
> > Well, the comment kinda says it already, but I will try to clarify it.
> > 
> >            /*
> >             * We have start:end spanning across an MTRR.
> >             * We split the region into either
> >             * - start_state:1
> >             *     (start:mtrr_end) (mtrr_end:end)
> >             * - end_state:1 or inclusive:1
> >             *     (start:mtrr_start) (mtrr_start:end)
> 
> What I mean is this:
> 
> 		* - start_state:1
> 		*     (start:mtrr_end) (mtrr_end:end)
> 		* - end_state:1
> 		*     (start:mtrr_start) (mtrr_start:end)
> 		* - inclusive:1
> 		*     (start:mtrr_start) (mtrr_start:mtrr_end) (mtrr_end:end)
> 		*
> 		* depending on kind of overlap.
> 		*
> 		* Return the type of the first region and a pointer to the start
> 		* of next region so that caller will be advised to lookup again
> 		* after having adjusted start and end.
> 		*
> 		* Note: This way we handle multiple overlaps as well.
> 		*/
> 
> We add comments so that people can read them and can quickly understand
> what the function does. Not to make them parse it and wonder why
> inclusive:1 is listed together with end_state:1 which returns two
> intervals.
> 
> Note that I changed the text to talk about the *next* region and not
> about the *second* region, to make it even more clear.

Thanks for the suggestion.  I see your point.  I will update it
accordingly.
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
