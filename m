Subject: Re: Kernel BUG at mm/rmap.c:491
From: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <Pine.LNX.4.61.0511240747590.5688@goblin.wat.veritas.com>
References: <200511232256.jANMuGg20547@unix-os.sc.intel.com>
	 <cone.1132788250.534735.25446.501@kolivas.org>
	 <200511232335.15050.s0348365@sms.ed.ac.uk>
	 <20051124044009.GE30849@redhat.com>
	 <Pine.LNX.4.61.0511240747590.5688@goblin.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 24 Nov 2005 06:33:12 -0500
Message-Id: <1132831993.3473.20.camel@mindpipe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Dave Jones <davej@redhat.com>, Alistair John Strachan <s0348365@sms.ed.ac.uk>, Con Kolivas <con@kolivas.org>, Kenneth W <kenneth.w.chen@intel.com>, Keith Owens <kaos@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-24 at 07:50 +0000, Hugh Dickins wrote:
> But I've CC'ed Keith,
> we sometimes find the kernel does things so to suit ksymoops. 

Um, unless someone has been merging Documentation patches without
reading them, ksymoops shouldn't be used with 2.6 anyway.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
