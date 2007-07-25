Received: by ug-out-1314.google.com with SMTP id c2so525922ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 16:45:21 -0700 (PDT)
Message-ID: <b8bf37780707251645j6ebcd71ao91363b3b90fb32f@mail.gmail.com>
Date: Wed, 25 Jul 2007 20:45:20 -0300
From: "=?ISO-8859-1?Q?Andr=E9_Goddard_Rosa?=" <andre.goddard@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <20070725150509.4d80a85e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <46A58B49.3050508@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <30701.1185347660@turing-police.cc.vt.edu> <46A7074B.50608@gmail.com>
	 <20070725082822.GA13098@elte.hu> <46A70D37.3060005@gmail.com>
	 <20070725113401.GA23341@elte.hu> <20070725150509.4d80a85e.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Ingo Molnar <mingo@elte.hu>, david@lang.hm, nickpiggin@yahoo.com.au, Valdis.Kletnieks@vt.edu, ray-lk@madrabbit.org, jesper.juhl@gmail.com, linux-kernel@vger.kernel.org, ck@vds.kolivas.org, linux-mm@kvack.org, akpm@linux-foundation.org, rene.herman@gmail.com
List-ID: <linux-mm.kvack.org>

> Question:
>   Could those who have found this prefetch helps them alot say how
>   many disks they have?  In particular, is their swap on the same
>   disk spindle as their root and user files?
>
> Answer - for me:
>   On my system where updatedb is a big problem, I have one, slow, disk.

On both desktop and laptop.

Cheers,
-- 
[]s,
Andre Goddard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
