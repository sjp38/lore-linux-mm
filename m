Date: Wed, 16 Jul 2003 14:53:08 +0200
From: Philippe =?ISO-8859-15?Q?Gramoull=E9?=
	<philippe.gramoulle@mmania.com>
Subject: Re: 2.6.0-test1-mm1
Message-Id: <20030716145308.44f5eb7b.philippe.gramoulle@mmania.com>
In-Reply-To: <20030715225608.0d3bff77.akpm@osdl.org>
References: <20030715225608.0d3bff77.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Andrew,

testing 2.6.0-test1-mm1 right now. Everything's been _really_ good so far.
I've been using 2.5.72-mm1 before since it's out without a problem.

make -j 16 bzImage + xmms + moving a term window like mad never makes Xmms skip
which is really good. Term window freezes for few seconds after moving it like mad for ~7/8 sec
(not a realy day to day typical workload ! :) And it comes back to normal almost as soon as i stop
moving the Eterm window.

I also have a Xinerama setup and no pb so far when moving like mad the Eterm windows from one
screen to the other or moving Eterm like mad wile overlapping the 2 screens.

Box is Dell WS 530 MT SMP 512 Mo , 15K RPM SCSI disk (AIC7xxx, 0 TCQ), Nvidia GeForce 256 AGP  NV10DDR + 
Nvidia NV6 Vanta LT PCI

boot option is : kernel /boot/vmlinuz-2.5.72-mm1 root=/dev/sda2 console=tty1 console=ttyS1,9600n8 elevator=as noirqbalance

Box is running postfix, Mozilla, Opera, NFS server, gnomeICU, etc.. and all is running fine ( subjective
opinion ;)

Congrats to all kernel hackers :)

Thanks,

Philippe

--

Philippe Gramoulle
philippe.gramoulle@mmania.com
System & Network Engineer
NOC France - Lycos Europe



On Tue, 15 Jul 2003 22:56:08 -0700
Andrew Morton <akpm@osdl.org> wrote:

  | . Another interactivity patch from Con.  Feedback is needed on this
  |   please - we cannot make much progress on this fairly subjective work
  |   without lots of people telling us how it is working for them.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
