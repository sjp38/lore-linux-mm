Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id B75256B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 03:31:11 -0500 (EST)
Date: Fri, 9 Nov 2012 09:32:03 +0100
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121109093203.4358eaf2@doriath>
In-Reply-To: <20121107105348.GA25549@lizard>
References: <20121107105348.GA25549@lizard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi Anton,

On Wed, 7 Nov 2012 02:53:49 -0800
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> Hi all,
> 
> This is the third RFC. As suggested by Minchan Kim, the API is much
> simplified now (comparing to vmevent_fd):

Which tree is this against? I'd like to try this series, but it doesn't
apply to Linus tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
