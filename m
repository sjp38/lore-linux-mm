Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 145C46B005D
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:31:32 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so1043887eek.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 03:31:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFz+Zi=A0uyuNMj411ngjwpstakNY3fEWy6tW_h4whr7w@mail.gmail.com>
References: <20121107105348.GA25549@lizard>
	<CAOJsxLFz+Zi=A0uyuNMj411ngjwpstakNY3fEWy6tW_h4whr7w@mail.gmail.com>
Date: Wed, 7 Nov 2012 13:31:30 +0200
Message-ID: <CAOJsxLGKsGVRosthKs2JfNro7dGAtZxZt-E2SWzq6wTpJN+wKg@mail.gmail.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 7, 2012 at 1:30 PM, Pekka Enberg <penberg@kernel.org> wrote:
> I love the API and implementation simplifications but I hate the new
> ABI. It's a specialized, single-purpose syscall and bunch of procfs
> tunables and I don't see how it's 'extensible' to anything but VM

s/anything but VM/anything but VM pressure notification/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
