Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 95B6C6B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 14:22:10 -0500 (EST)
Date: Mon, 19 Nov 2012 20:22:09 +0100
From: Damien Wyart <damien.wyart@free.fr>
Subject: Re: [PATCHv5] mm: Fix calculation of dirtyable memory
Message-ID: <20121119192209.GA3718@brouette>
References: <20121119134001.GA2799@cmpxchg.org>
 <1353350518-32623-1-git-send-email-sonnyrao@chromium.org>
 <CAPz6YkXazpiJgKHnQx=dpr4XOCo8J_PBeffDG7mfPk7rPy2a-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPz6YkXazpiJgKHnQx=dpr4XOCo8J_PBeffDG7mfPk7rPy2a-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sonny Rao <sonnyrao@chromium.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>, Johannes Weiner <jweiner@redhat.com>, Olof Johansson <olofj@chromium.org>, Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>, Aaron Durbin <adurbin@chromium.org>, stable@vger.kernel.org, Puneet Kumar <puneetster@chromium.org>, linux-kernel@vger.kernel.org

* Sonny Rao <sonnyrao@chromium.org> [2012-11-19 10:44]:
> Damien, thanks for testing and finding that bug.  If you could, please
> give this version a try, thanks.

Tried it for a few hours (as soon as the min/max problem was suggested
on the list) and the previous problems disappeared.

-- 
Damien

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
