Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 14AC06B005A
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:28:14 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so1041722eek.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 03:28:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121107112136.GA31715@shutemov.name>
References: <20121107105348.GA25549@lizard>
	<20121107112136.GA31715@shutemov.name>
Date: Wed, 7 Nov 2012 13:28:12 +0200
Message-ID: <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 7, 2012 at 1:21 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>> While the new API is very simple, it is still extensible (i.e. versioned).
>
> Sorry, I didn't follow previous discussion on this, but could you
> explain what's wrong with memory notifications from memcg?
> As I can see you can get pretty similar functionality using memory
> thresholds on the root cgroup. What's the point?

Why should you be required to use cgroups to get VM pressure events to
userspace?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
