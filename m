Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D965A6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 15:52:59 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id p5so1957501lag.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 12:52:57 -0800 (PST)
Message-ID: <509ACA28.307@kernel.org>
Date: Wed, 07 Nov 2012 22:52:56 +0200
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <xr93liedfhy4.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93liedfhy4.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi Greg,

On 11/7/12 7:20 PM, Greg Thelen wrote:
 > Related question: are there plans to extend this system call to
 > provide per-cgroup vm pressure notification?

Yes, that's something that needs to be addressed before we can ever
consider merging something like this to mainline.  We probably need help
with that, though. Preferably from someone who knows cgroups. :-)

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
