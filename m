Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BF8B36B005C
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 17:15:12 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so5757164vcb.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 14:15:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1781399.9f45Chd7K4@wuerfel>
References: <1322816252-19955-1-git-send-email-sumit.semwal@ti.com>
	<201112051718.48324.arnd@arndb.de>
	<CAF6AEGvyWV0DM2fjBbh-TNHiMmiLF4EQDJ6Uu0=NkopM6SXS6g@mail.gmail.com>
	<1781399.9f45Chd7K4@wuerfel>
Date: Mon, 5 Dec 2011 16:15:11 -0600
Message-ID: <CAF6AEGsiSL8x6qETm5zPaQe08=NYOD8eZsASx0e0hkjK3YEj2Q@mail.gmail.com>
Subject: Re: [RFC v2 1/2] dma-buf: Introduce dma buffer sharing mechanism
From: Rob Clark <rob@ti.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, t.stanislaws@samsung.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-media@vger.kernel.org, Sumit Semwal <sumit.semwal@linaro.org>, m.szyprowski@samsung.com

On Mon, Dec 5, 2011 at 4:09 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>> https://github.com/robclark/kernel-omap4/commits/dmabuf
>
> Ok, thanks. I think it would be good to post these for reference
> in v3, with a clear indication that they are not being submitted
> for discussion/inclusion yet.

btw, don't look at this too closely at that tree yet.. where the
attach/detach is done in videobuf2 code isn't really correct.  But I
was going to get something functioning first.

BR,
-R

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
