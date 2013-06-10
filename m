Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D1F156B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 01:58:16 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id x54so3607527wes.4
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 22:58:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
References: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
Date: Mon, 10 Jun 2013 11:28:15 +0530
Message-ID: <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
Subject: Re: [checkpatch] - Confusion
From: anish singh <anish198519851985@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jun 10, 2013 at 11:21 AM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrote:
> Hi,
>
> I wanted to submit my first patch.
> But I have some confusion about the /scripts/checkpatch.pl errors.
>
> After correcting some checkpatch errors, when I run checkpatch.pl, it showed me 0 errors.
> But when I create patches are git format-patch, it is showing me 1 error.
did  you run the checkpatch.pl on the file which gets created
after git format-patch?
If yes, then I think it is not necessary.You can use git-am to apply
your own patch on a undisturbed file and if it applies properly then
you are good to go i.e. you can send your patch.
>
> If I fix error in patch, it showed me back again in files.
>
> Now, I am confused which error to fix while submitting patches, the file or the patch errors.
>
> Please provide your opinion.
>
> File: mm/page_alloc.c
> Previous file errors:
> total: 16 errors, 110 warnings, 6255 lines checked
>
> After fixing errors:
> total: 0 errors, 105 warnings, 6255 lines checked
>
>
> And, after running on patch:
> ERROR: need consistent spacing around '*' (ctx:WxV)
> #153: FILE: mm/page_alloc.c:5476:
> +int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
>
>
>
>
> - Pintu
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
