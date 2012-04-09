Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 19C286B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 04:21:07 -0400 (EDT)
Received: by lbao2 with SMTP id o2so2160365lba.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 01:21:05 -0700 (PDT)
Date: Mon, 9 Apr 2012 11:20:57 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/3] vmevent-test: No need for SDL library
In-Reply-To: <20120408233820.GB4839@panacea>
Message-ID: <alpine.LFD.2.02.1204091120490.6479@tux.localdomain>
References: <20120408233550.GA3791@panacea> <20120408233820.GB4839@panacea>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

On Mon, 9 Apr 2012, Anton Vorontsov wrote:
> panacea:~/src/linux/linux-vmevent/tools/testing/vmevent$ make
> cc -O3 -g -std=gnu99 -Wcast-align -Wformat -Wformat-security
> -Wformat-y2k -Wshadow -Winit-self -Wpacked -Wredundant-decls
> -Wstrict-aliasing=3 -Wswitch-default -Wno-system-headers -Wundef
> -Wwrite-strings -Wbad-function-cast -Wmissing-declarations
> -Wmissing-prototypes -Wnested-externs -Wold-style-definition
> -Wstrict-prototypes -Wdeclaration-after-statement  -lSDL  vmevent-test.c
> -o vmevent-test
> /usr/bin/ld: cannot find -lSDL
> collect2: ld returned 1 exit status
> make: *** [vmevent-test] Error 1
> 
> This patch fixes the issue.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
