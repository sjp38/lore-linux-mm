Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 3 Feb 2015 18:25:21 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 2/2] aio: make aio .mremap handle size changes
Message-ID: <20150203232521.GB14400@kvack.org>
References: <b885312bcea6e8c89889412936fb93305a4d139d.1422986358.git.shli@fb.com> <798fafb96373cfab0707457a266dd137016cd1e9.1422986358.git.shli@fb.com> <20150203192323.GT2974@kvack.org> <20150203193115.GA296459@devbig257.prn2.facebook.com> <20150203194828.GU2974@kvack.org> <20150203213150.GA543371@devbig257.prn2.facebook.com> <20150203214749.GA14400@kvack.org> <20150203225845.GA749607@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203225845.GA749607@devbig257.prn2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 03, 2015 at 02:58:45PM -0800, Shaohua Li wrote:
> That's too complex. Don't think I'll spend time on the no-usage
> functionality. Will leave it be if you don't like the sample workaround.

I'll fix the mremap case to disable resizing the ring buffer myself then.

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
