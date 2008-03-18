In-reply-to: <1205848760.8514.366.camel@twins> (message from Peter Zijlstra on
	Tue, 18 Mar 2008 14:59:20 +0100)
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
	end_page_writeback()
References: <20080317191908.123631326@szeredi.hu>
	 <20080317191945.122011759@szeredi.hu> <1205840031.8514.346.camel@twins>
	 <E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu> <1205843375.8514.357.camel@twins>
	 <E1JbbHf-0005rm-R5@pomaz-ex.szeredi.hu> <1205845702.8514.365.camel@twins>
	 <E1JbcKL-00060V-9N@pomaz-ex.szeredi.hu> <1205848760.8514.366.camel@twins>
Message-Id: <E1Jbe8O-0006H7-E4@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 18 Mar 2008 16:53:52 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: peterz@infradead.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Well, but this is the kernel, you can't really make foolproof
> > interfaces.  If we'll go with Andrew's suggestion, I'll add comments
> > warning users about not touching those flags unless they know what
> > they are doing, OK?
> 
> Yeah, I guess so :-)

Cool :)

On a related note, is there a reason why bdi_cap_writeback_dirty() and
friends need to be macros instead of inline functions?  If not I'd
clean that up as well.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
