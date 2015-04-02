Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id BCCC66B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 14:52:09 -0400 (EDT)
Received: by widdi4 with SMTP id di4so88239986wid.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 11:52:09 -0700 (PDT)
Received: from lb3-smtp-cloud2.xs4all.net (lb3-smtp-cloud2.xs4all.net. [194.109.24.29])
        by mx.google.com with ESMTPS id sc1si10270813wjb.114.2015.04.02.11.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 02 Apr 2015 11:52:08 -0700 (PDT)
Message-ID: <1428000723.10518.70.camel@x220>
Subject: Re: mmotm 2015-04-01-14-54 uploaded
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 02 Apr 2015 20:52:03 +0200
In-Reply-To: <551D0101.6000301@arm.com>
References: <551c6943.H+vcYDrtw2kStb+B%akpm@linux-foundation.org>
	 <551D0101.6000301@arm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: valentinrothberg@gmail.com, rupran@einserver.de, stefan.hengelein@fau.de, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "mhocko@suse.cz" <mhocko@suse.cz>

On Thu, 2015-04-02 at 09:42 +0100, Vladimir Murzin wrote:
> It was noticed by Paul Bolle (and his clever bot) that patch above
> simply disables MEMTEST altogether [1]. 

This needs correcting.

The clever bot is a project of Andreas Ruprecht, Stefan Hengelein, and
Valentin Rothberg. I've only been cheering their efforts.

I noticed this issue because I wrote a 800 line perl monster that checks
this stuff. It's only slightly more advanced than
scripts/checkkconfigsymbols.py (which Stefan and Valentin wrote). And
I'm sure that python script would have spotted this issue too.

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
