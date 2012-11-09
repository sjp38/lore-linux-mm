Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 498BC6B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 19:45:54 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id s11so79269qaa.14
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 16:45:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1352421724-5366-1-git-send-email-sonnyrao@chromium.org>
References: <20121108153756.cca505da.akpm@linux-foundation.org> <1352421724-5366-1-git-send-email-sonnyrao@chromium.org>
From: Sonny Rao <sonnyrao@chromium.org>
Date: Thu, 8 Nov 2012 16:45:33 -0800
Message-ID: <CAPz6YkVruULzvmn4a8G05xPJUEXdhHqAZnW4sZAHCWMZpW338g@mail.gmail.com>
Subject: Re: [PATCHv2] mm: Fix calculation of dirtyable memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Mandeep Singh Baines <msb@chromium.org>, Johannes Weiner <jweiner@redhat.com>, Olof Johansson <olofj@chromium.org>, Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>, Aaron Durbin <adurbin@chromium.org>

On Thu, Nov 8, 2012 at 4:42 PM, Sonny Rao <sonnyrao@chromium.org> wrote:
> add apkm's suggestion
>

Oops, sorry, will add akpm's suggestion and re-post

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
