Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 5E4966B0071
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 06:59:38 -0500 (EST)
Date: Mon, 16 Jan 2012 13:59:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RESEND, PATCH 6/6] memcg: cleanup memcg_check_events()
Message-ID: <20120116115957.GB25687@shutemov.name>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
 <1325883472-5614-6-git-send-email-kirill@shutemov.name>
 <20120109134108.GF3588@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120109134108.GF3588@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, Jan 09, 2012 at 02:41:08PM +0100, Johannes Weiner wrote:
> On Fri, Jan 06, 2012 at 10:57:52PM +0200, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

...

> I'm about to remove the soft limit part of this code, so we'll be able
> to condense this back into a single #if block again, anyway.
> 
> I would much prefer having the extra #if in the code over this patch
> just to silence the warning for now.

The patch is informative only. I agree with Michal Hocko. It introduce too
much noise to fix one warning. Just ignore it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
