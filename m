Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9F2C96B005D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:41:45 -0500 (EST)
Date: Wed, 7 Nov 2012 13:43:22 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121107114321.GA32265@shutemov.name>
References: <20121107105348.GA25549@lizard>
 <20121107112136.GA31715@shutemov.name>
 <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 07, 2012 at 01:28:12PM +0200, Pekka Enberg wrote:
> On Wed, Nov 7, 2012 at 1:21 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >> While the new API is very simple, it is still extensible (i.e. versioned).
> >
> > Sorry, I didn't follow previous discussion on this, but could you
> > explain what's wrong with memory notifications from memcg?
> > As I can see you can get pretty similar functionality using memory
> > thresholds on the root cgroup. What's the point?
> 
> Why should you be required to use cgroups to get VM pressure events to
> userspace?

Valid point. But in fact you have it on most systems anyway.

I personally don't like to have a syscall per small feature.
Isn't it better to have a file-based interface which can be used with
normal file syscalls: open()/read()/poll()?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
