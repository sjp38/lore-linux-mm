Message-ID: <396A4080.136995CF@folkwang.uni-essen.de>
Date: Mon, 10 Jul 2000 23:30:40 +0200
From: =?iso-8859-1?Q?J=F6rn?= Nettingsmeier
        <nettings@folkwang.uni-essen.de>
MIME-Version: 1.0
Subject: Re: [linux-audio-dev] Re: new latency report
References: <E13BL8P-00022Z-00@the-village.bc.nu> <00070920393600.02245@smp>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benno Senoner <sbenno@gardena.net>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Roger Larsson <roger.larsson@norran.net>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

Benno Senoner wrote:
> So a  way to avoid latency peaks would be to inform the user, that
> if (during his audio recording sessions) he wants to do some stuff which
> requires module loading , he has to preload the modules at boottime,
> and disable automatic module cleanup.
> 
> Anyone better ideas ?
> 
> Benno.

i think it's a bad approach to add some warning kludge to modprobe.
keep these tools lean and mean - besides, we wouldn't stand a chance
fiddling with modutils on lkml :)

it's no big deal telling the users to have all modules loaded on
startup and no autoclean.
low-latency users will be willing to take this small effort, and
audio boxen tend to have lots of memory, so dynamic unloading will
not be necessary.

just my....



jorn


-- 
Jorn Nettingsmeier     
Kurfurstenstr. 49        
45138 Essen, Germany      
http://www.folkwang.uni-essen.de/~nettings/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
