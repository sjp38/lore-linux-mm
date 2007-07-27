Message-ID: <46A98A14.3040300@gmail.com>
Date: Fri, 27 Jul 2007 08:00:52 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com>	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>	 <46A81C39.4050009@gmail.com>	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com> <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>
In-Reply-To: <9a8748490707261746p638e4a98p3cdb7d9912af068a@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
Cc: Andika Triwidada <andika@gmail.com>, Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/27/2007 02:46 AM, Jesper Juhl wrote:

> On 26/07/07, Andika Triwidada <andika@gmail.com> wrote:

>> Might be insignificant, but updatedb calls find (~2M) and sort (~26M). 
>> Definitely not RAM intensive though (RAM is 1GB).
> 
> That doesn't match my box at all :

[ ... ]

> This is a Slackware Linux 12.0 system.

Yes, already identified that there are more updatedb's around. We are using 
"Secure Locate" and others simply the locate from the GNU findutils. Either 
version does not itself use significant memory though and seems irrelevant 
to the orginal swap-prefetch issue -- if updatedb filled memory with inodes 
and dentries the memory is no longer free and swap-prefetch can't prefetch 
anything.

The remaining issue of updatedb unnecessarily blowing away VFS caches is 
being discussed (*) in a few thread-branches still running.

Rene.

(*) I so much wanted to say "buried".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
