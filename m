Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C6B9C8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:10:00 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104201149520.12154@router.home>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com>
	 <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	 <20110420174027.4631.A69D9226@jp.fujitsu.com>
	 <1303317178.2587.30.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201149520.12154@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 13:09:55 -0500
Message-ID: <1303322995.2587.42.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, 2011-04-20 at 11:50 -0500, Christoph Lameter wrote:
> > I'm afraid it doesn't boot (it's another slub crash):
> 
> Is there any simulator available that we can use to run a parisc boot?

I don't think we have a simulator.  However, if you send a ssh key to

T-Bone@parisc-linux.org

He can loan you remote access to one of the systems that ESIEE in France
hosts for us.  (he's expecting you).

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
