Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: Another Mindcradt case?
Date: Tue, 6 Feb 2001 23:02:01 +0100
References: <200102062024.VAA15550@front3.grolier.fr>
In-Reply-To: <200102062024.VAA15550@front3.grolier.fr>
MIME-Version: 1.0
Message-Id: <01020623020100.01503@dox>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jean Francois Martinez <jfm2@club-internet.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Please note that Moshe is (usually) very pro Linux (read his earlier columns).
I guess that he had expected Linux 2.4 to really beat FreeBSD - it did not...

/RogerL 

On Wednesday 07 February 2001 01:25, Jean Francois Martinez wrote:
> Moshe Barr is claiming on Byte that sendmail and mysql are 30% faster on
> FreeBSD than Linux 2.4.   Now given that I don't think that mysql is
> spending 30% of its time in kernel mode there are not many ways FreeBSD can
> be 30% faster.
>
> 1) Compiler issues.  Moshe Barr does not tell what distrib ha was using so
> we don't know what distribution was used and with what
>
> 2) Driver problems, specally those related to enabling UltraDma since
> without UltraDMA most disks are both very slow and CPU hogs.
>
> 3) Options not enabled.  This a 2.2 Linux distrib with a 2.4 keernel
> plastered on it and thus software has not been compiled to take advantage
> of 2.4bfeatures and the boot sequence does not do a good job of tuning the
> kernel through sysctl
>
> 4) Memory management.  If FreeBSD is smarter than Linux about which page to
> thow out it will be _much_ faster when memory is tight.
>
>
> Now what about a Mindcraft-style reaction?  Check what was wrong in the
> test protocol, write an answer if it was due to the test and in case it was
> not the test but a perfomance bottleneck fix it.
>
> Moshe (and a few other people will do the same) was wondering why to stay
> with Linux so better fix the problems if we want Linux and not BSD reaching
> world domination.
>
>
> 									JF
> Martinez
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

-- 
Home page:
  none currently

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
