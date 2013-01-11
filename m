Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id A23076B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 14:13:58 -0500 (EST)
Date: Fri, 11 Jan 2013 17:13:55 -0200
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/2] Mempressure cgroup
Message-ID: <20130111171355.3f5cf87e@doriath.home>
In-Reply-To: <20130104082751.GA22227@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, 4 Jan 2013 00:27:52 -0800
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> - I've split the pach into two: 'shrinker' and 'levels' parts. While the
>   full-fledged userland shrinker is an interesting idea, we don't have any
>   users ready for it, so I won't advocate for it too much.

For the next version of the automatic balloon prototype I'm planning to give
the user-space shrinker a try. It seems to be a better fit, as the current
prototype has to guess by how much a guest's balloon should be inflated.

Also, I think it would be worth it to list possible use-cases for the two
functionalities in the series' intro email. This might help choosing both,
one or another.

Looking forward to the next version :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
