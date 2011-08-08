Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 042516B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 14:19:11 -0400 (EDT)
Received: by qyk7 with SMTP id 7so3004553qyk.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 11:19:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC5umyiUY3xSbpnd2z79JG-vi8voFMvCc=qeiJrDKiq869QmyQ@mail.gmail.com>
References: <1312195957-12223-1-git-send-email-per.forlin@linaro.org>
	<1312195957-12223-2-git-send-email-per.forlin@linaro.org>
	<CAC5umyiUY3xSbpnd2z79JG-vi8voFMvCc=qeiJrDKiq869QmyQ@mail.gmail.com>
Date: Mon, 8 Aug 2011 20:19:10 +0200
Message-ID: <CAJ0pr19Wx-d6wVD9UX+kzHkREeJg0yNNc8wABLYD6G-P0xFXSA@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/2] fault-injection: improve naming of public
 function should_fail()
From: Per Forlin <per.forlin@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On 8 August 2011 18:16, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 2011/8/1 Per Forlin <per.forlin@linaro.org>:
>> rename fault injection function should_fail() to fault_should_fail()
>
> fault_should_fail sounds tautological.
> fault_should_inject() is better, but I'm not sure.
> Should we retain the naming issue and go forward to merge mmc fault
> injection first?
>
Fine with me.
I'll go ahead and prepare the mmc failt-injection patches based on
current naming.

Thanks,
Per

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
