Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 188246B006C
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 06:53:57 -0500 (EST)
Date: Mon, 16 Jan 2012 13:54:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RESEND, PATCH 4/6] memcg: fix broken boolean expression
Message-ID: <20120116115416.GA25687@shutemov.name>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
 <1325883472-5614-4-git-send-email-kirill@shutemov.name>
 <20120109140404.GG3588@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120109140404.GG3588@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, stable@kernel.org

On Mon, Jan 09, 2012 at 03:04:04PM +0100, Johannes Weiner wrote:
> On Fri, Jan 06, 2012 at 10:57:50PM +0200, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > 
> > action != CPU_DEAD || action != CPU_DEAD_FROZEN is always true.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: <stable@kernel.org>
> 
> I think you don't need to actually CC stable via email.  If you
> include that tag, they will pick it up once the patch hits mainline.

I don't think it's a problem for stable@.

> 
> The changelog is too terse, doubly so for a patch that should go into
> stable.  How is the code supposed to work?  What are the consequences
> of the bug?

Is it enough?

---
