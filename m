Message-ID: <46A851F8.7080006@gmail.com>
Date: Thu, 26 Jul 2007 09:49:12 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com> <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
In-Reply-To: <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andika Triwidada <andika@gmail.com>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/26/2007 08:23 AM, Andika Triwidada wrote:

> On 7/26/07, Rene Herman <rene.herman@gmail.com> wrote:

>> RAM intensive? If I run updatedb here, it never grows itself beyond 2M.
>> Yes, two. I'm certainly willing to accept that me and my systems are 
>> possibly not the reference but assuming I'm _very_ special hasn't done
>> much for me either in the past.
> 
> Might be insignificant, but updatedb calls find (~2M) and sort (~26M).

It does? My updatedb certainly doesn't seem to (slackware 12.0). It's using 
"Secure Locate". Different distributions using different versions of locate 
it seems?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
