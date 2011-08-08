Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3D50B6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 12:16:27 -0400 (EDT)
Received: by vwm42 with SMTP id 42so3541235vwm.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 09:16:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312195957-12223-2-git-send-email-per.forlin@linaro.org>
References: <1312195957-12223-1-git-send-email-per.forlin@linaro.org>
	<1312195957-12223-2-git-send-email-per.forlin@linaro.org>
Date: Tue, 9 Aug 2011 01:16:20 +0900
Message-ID: <CAC5umyiUY3xSbpnd2z79JG-vi8voFMvCc=qeiJrDKiq869QmyQ@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/2] fault-injection: improve naming of public
 function should_fail()
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Per Forlin <per.forlin@linaro.org>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Jens Axboe <axboe@kernel.dk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

2011/8/1 Per Forlin <per.forlin@linaro.org>:
> rename fault injection function should_fail() to fault_should_fail()

fault_should_fail sounds tautological.
fault_should_inject() is better, but I'm not sure.
Should we retain the naming issue and go forward to merge mmc fault
injection first?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
