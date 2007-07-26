Received: by ug-out-1314.google.com with SMTP id c2so595433ugf
        for <linux-mm@kvack.org>; Thu, 26 Jul 2007 02:37:17 -0700 (PDT)
Message-ID: <7e0bae390707260237i269e4df9j97b4f2144343f5b8@mail.gmail.com>
Date: Thu, 26 Jul 2007 16:37:17 +0700
From: "Andika Triwidada" <andika@gmail.com>
Subject: Re: updatedb
In-Reply-To: <46A851F8.7080006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>
	 <46A773EA.5030103@gmail.com>
	 <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
	 <46A81C39.4050009@gmail.com>
	 <7e0bae390707252323k2552c701x5673c55ff2cf119e@mail.gmail.com>
	 <46A851F8.7080006@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/26/07, Rene Herman <rene.herman@gmail.com> wrote:
> On 07/26/2007 08:23 AM, Andika Triwidada wrote:
>
> > On 7/26/07, Rene Herman <rene.herman@gmail.com> wrote:
>
> >> RAM intensive? If I run updatedb here, it never grows itself beyond 2M.
> >> Yes, two. I'm certainly willing to accept that me and my systems are
> >> possibly not the reference but assuming I'm _very_ special hasn't done
> >> much for me either in the past.
> >
> > Might be insignificant, but updatedb calls find (~2M) and sort (~26M).
>
> It does? My updatedb certainly doesn't seem to (slackware 12.0). It's using
> "Secure Locate". Different distributions using different versions of locate
> it seems?
>
> Rene.
>


I'm using Debian Sid, updatedb is from package findutils v4.2.31

-- 
andika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
