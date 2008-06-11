Received: by ug-out-1314.google.com with SMTP id h3so29602ugf.29
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 00:31:10 -0700 (PDT)
Date: Wed, 11 Jun 2008 09:31:01 +0200
From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
Message-ID: <20080611073101.GA3591@slug>
References: <20080611060029.GA5011@martell.zuzino.mipt.ru> <20080610232705.3aaf5c06.akpm@linux-foundation.org> <20080611153457.7882.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080611153457.7882.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 11, 2008 at 03:36:40PM +0900, KOSAKI Motohiro wrote:
> > > vm.overcommit_memory = 0
> > > vm.overcommit_ratio = 50
> > 
> > Well I assume that Rik ran LTP.  Perhaps a merge problem.
> 
> at least, I ran LTP last week and its error didn't happend.
> I'll investigate more.
FWIW, I can reproduce it reliably:
$ cd <ltp-dir>/testcases/bin
$ ./growfiles -W gf15 -b -e 1 -u -r 1-49600 -I r -u -i 0 -L 120 Lgfile1
And then wait for a few secs before the OOM triggers.

Regards,
Frederik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
