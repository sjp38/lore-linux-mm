Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2F07B6B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 02:44:54 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so5099139wib.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 23:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121025064009.GA15767@bbox>
References: <20121022111928.GA12396@lizard>
	<20121025064009.GA15767@bbox>
Date: Thu, 25 Oct 2012 09:44:52 +0300
Message-ID: <CAOJsxLGsjTe13WjY_Q=BLBELwQXOjuwo7PiEKwONHUfR4mQmig@mail.gmail.com>
Subject: Re: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs +
 man page
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, Oct 25, 2012 at 9:40 AM, Minchan Kim <minchan@kernel.org> wrote:
> Your description doesn't include why we need new vmevent_fd(2).
> Of course, it's very flexible and potential to add new VM knob easily but
> the thing we is about to use now is only VMEVENT_ATTR_PRESSURE.
> Is there any other use cases for swap or free? or potential user?
> Adding vmevent_fd without them is rather overkill.

What ABI would you use instead?

On Thu, Oct 25, 2012 at 9:40 AM, Minchan Kim <minchan@kernel.org> wrote:
> I don't object but we need rationale for adding new system call which should
> be maintained forever once we add it.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
