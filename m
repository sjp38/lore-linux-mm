Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 846F56B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 04:13:11 -0500 (EST)
Date: Wed, 9 Jan 2013 01:15:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-Id: <20130109011512.a87ffdfa.akpm@linux-foundation.org>
In-Reply-To: <50ED30CE.8070208@parallels.com>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
	<1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
	<50ED30CE.8070208@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, 9 Jan 2013 12:56:46 +0400 Glauber Costa <glommer@parallels.com> wrote:

> > +#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_MEMPRESSURE)
> > +SUBSYS(mpc_cgroup)
> > +#endif
> 
> It might be just me, but if one does not know what this is about, "mpc"
> immediately fetches something communication-related to mind. I would
> suggest changing this to just plain "mempressure_cgroup", or something
> more descriptive.

mempressure_cgroup is rather lengthy.  "mpcg" would be good - it's short
and rememberable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
