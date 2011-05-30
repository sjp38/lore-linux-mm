Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD726B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 06:51:09 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so1715633gwa.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 03:51:01 -0700 (PDT)
Received: by gwaa12 with SMTP id a12so1715631gwa.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 03:51:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110530112355.e92a58c0.kamezawa.hiroyu@jp.fujitsu.com>
References: <4DE2BFA2.3030309@simplicitymedialtd.co.uk>
	<4DE2C787.1050809@simplicitymedialtd.co.uk>
	<20110530112355.e92a58c0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 30 May 2011 11:51:00 +0100
Message-ID: <BANLkTikheK8O3v5HvCcKE7iiAfauDq7NhQ@mail.gmail.com>
Subject: Re: Fwd: cgroup OOM killer loop causes system to lockup (possible fix included)
From: "Cal Leeming [Simplicity Media Ltd]" <cal.leeming@simplicitymedialtd.co.uk>
Content-Type: multipart/alternative; boundary=000e0cd286b423464f04a47c10fe
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "rientjes@google.com" <rientjes@google.com>

--000e0cd286b423464f04a47c10fe
Content-Type: text/plain; charset=ISO-8859-1

@Kame
Thanks for the reply!

Both kernels used the same env/dist, but which slightly different packages.

After many frustrating hours, I have pin pointed this down to a dodgy Debian
package which appears to continue affecting the system, even after purging.
I'm still yet to pin point the package down (I'm doing several reinstall
tests, along with tripwire analysis after each reboot).

@Hiroyuki
Thank you for sending this to the right people!

@linux-mm
On a side note, would someone mind taking a few minutes to give a brief
explanation as to how the default oom_adj is set, and under what conditions
it is given -17 by default? Is this defined by the application? I looked
through the kernel source, and noticed some of the code was defaulted to set
oom_adj to OOM_DISABLE (which is defined in the headers as -17).

Assuming the debian problem is resolved, this might be another call for the
oom-killer to be modified so that if it encounters the unrecoverable loop,
it ignores the -17 rule (with some exceptions, such as kernel processes, and
other critical things). If this is going to be a relatively simple task, I
wouldn't mind spending a few hours patching this?

Cal

On Mon, May 30, 2011 at 3:23 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> Thank you. memory cgroup and OOM troubles are handled in linux-mm.
>
> On Sun, 29 May 2011 23:24:07 +0100
> "Cal Leeming [Simplicity Media Ltd]"  <
> cal.leeming@simplicitymedialtd.co.uk> wrote:
>
> > Some further logs:
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369927] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369939]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399285] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399296]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428690] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428702]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487696] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487708]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517023] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517035]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546379] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546391]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310789] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310804]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369918] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369930]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399284] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399296]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433634] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433648]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463947] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463959]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493439] redis-server
> > invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=-17
> > ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493451]
> > [<ffffffff810b12b7>] ? oom_kill_process+0x82/0x283
> >
> >
>
> hmm, in short, applications has -17 oom_adj in default with 2.6.32.41 ?
> AFAIK, no kernel has such crazy settings as default..
>
> Does your 2 kernel uses the same environment/distribution ?
>
> Thanks,
> -Kame
>
> > On 29/05/2011 22:50, Cal Leeming [Simplicity Media Ltd] wrote:
> > >  First of all, my apologies if I have submitted this problem to the
> > > wrong place, spent 20 minutes trying to figure out where it needs to
> > > be sent, and was still none the wiser.
> > >
> > > The problem is related to applying memory limitations within a cgroup.
> > > If the OOM killer kicks in, it gets stuck in a loop where it tries to
> > > kill a process which has an oom_adj of -17. This causes an infinite
> > > loop, which in turn locks up the system.
> > >
> > > May 30 03:13:08 vicky kernel: [ 1578.117055] Memory cgroup out of
> > > memory: kill process 6016 (java) score 0 or a child
> > > May 30 03:13:08 vicky kernel: [ 1578.117154] Memory cgroup out of
> > > memory: kill process 6016 (java) score 0 or a child
> > > May 30 03:13:08 vicky kernel: [ 1578.117248] Memory cgroup out of
> > > memory: kill process 6016 (java) score 0 or a child
> > > May 30 03:13:08 vicky kernel: [ 1578.117343] Memory cgroup out of
> > > memory: kill process 6016 (java) score 0 or a child
> > > May 30 03:13:08 vicky kernel: [ 1578.117441] Memory cgroup out of
> > > memory: kill process 6016 (java) score 0 or a child
> > >
> > >
> > >  root@vicky [/home/foxx] > uname -a
> > > Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64
> > > GNU/Linux
> > > (this happens on both the grsec patched and non patched 2.6.32.41
> kernel)
> > >
> > > When this is encountered, the memory usage across the whole server is
> > > still within limits (not even hitting swap).
> > >
> > > The memory configuration for the cgroup/lxc is:
> > > lxc.cgroup.memory.limit_in_bytes = 3000M
> > > lxc.cgroup.memory.memsw.limit_in_bytes = 3128M
> > >
> > > Now, what is even more strange, is that when running under the
> > > 2.6.32.28 kernel (both patched and unpatched), this problem doesn't
> > > happen. However, there is a slight difference between the two kernels.
> > > The 2.6.32.28 kernel gives a default of 0 in the /proc/X/oom_adj,
> > > where as the 2.6.32.41 gives a default of -17. I suspect this is the
> > > root cause of why it's showing in the later kernel, but not the
> earlier.
> > >
> > > To test this theory, I started up the lxc on both servers, and then
> > > ran a one liner which showed me all the processes with an oom_adj of
> -17:
> > >
> > > (the below is the older/working kernel)
> > > root@courtney.internal [/mnt/encstore/lxc] > uname -a
> > > Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb 18 16:09:07 GMT
> > > 2011 x86_64 GNU/Linux
> > > root@courtney.internal [/mnt/encstore/lxc] > for x in `find /proc
> > > -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print $3}'` ; do
> > > ps -p $x --no-headers ; done
> > > grep: /proc/1411/task/1411/oom_adj: No such file or directory
> > > grep: /proc/1411/oom_adj: No such file or directory
> > >   804 ?        00:00:00 udevd
> > >   804 ?        00:00:00 udevd
> > > 25536 ?        00:00:00 sshd
> > > 25536 ?        00:00:00 sshd
> > > 31861 ?        00:00:00 sshd
> > > 31861 ?        00:00:00 sshd
> > > 32173 ?        00:00:00 udevd
> > > 32173 ?        00:00:00 udevd
> > > 32174 ?        00:00:00 udevd
> > > 32174 ?        00:00:00 udevd
> > >
> > > (the below is the newer/broken kernel)
> > >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > uname -a
> > > Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x86_64
> > > GNU/Linux
> > >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > for x in
> > > `find /proc -iname 'oom_adj' | xargs grep "\-17"  | awk -F '/' '{print
> > > $3}'` ; do ps -p $x --no-headers ; done
> > > grep: /proc/3118/task/3118/oom_adj: No such file or directory
> > > grep: /proc/3118/oom_adj: No such file or directory
> > >   895 ?        00:00:00 udevd
> > >   895 ?        00:00:00 udevd
> > >  1091 ?        00:00:00 udevd
> > >  1091 ?        00:00:00 udevd
> > >  1092 ?        00:00:00 udevd
> > >  1092 ?        00:00:00 udevd
> > >  2596 ?        00:00:00 sshd
> > >  2596 ?        00:00:00 sshd
> > >  2608 ?        00:00:00 sshd
> > >  2608 ?        00:00:00 sshd
> > >  2613 ?        00:00:00 sshd
> > >  2613 ?        00:00:00 sshd
> > >  2614 pts/0    00:00:00 bash
> > >  2614 pts/0    00:00:00 bash
> > >  2620 pts/0    00:00:00 sudo
> > >  2620 pts/0    00:00:00 sudo
> > >  2621 pts/0    00:00:00 su
> > >  2621 pts/0    00:00:00 su
> > >  2622 pts/0    00:00:00 bash
> > >  2622 pts/0    00:00:00 bash
> > >  2685 ?        00:00:00 lxc-start
> > >  2685 ?        00:00:00 lxc-start
> > >  2699 ?        00:00:00 init
> > >  2699 ?        00:00:00 init
> > >  2939 ?        00:00:00 rc
> > >  2939 ?        00:00:00 rc
> > >  2942 ?        00:00:00 startpar
> > >  2942 ?        00:00:00 startpar
> > >  2964 ?        00:00:00 rsyslogd
> > >  2964 ?        00:00:00 rsyslogd
> > >  2964 ?        00:00:00 rsyslogd
> > >  2964 ?        00:00:00 rsyslogd
> > >  2980 ?        00:00:00 startpar
> > >  2980 ?        00:00:00 startpar
> > >  2981 ?        00:00:00 ctlscript.sh
> > >  2981 ?        00:00:00 ctlscript.sh
> > >  3016 ?        00:00:00 cron
> > >  3016 ?        00:00:00 cron
> > >  3025 ?        00:00:00 mysqld_safe
> > >  3025 ?        00:00:00 mysqld_safe
> > >  3032 ?        00:00:00 sshd
> > >  3032 ?        00:00:00 sshd
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3097 ?        00:00:00 mysqld.bin
> > >  3113 ?        00:00:00 ctl.sh
> > >  3113 ?        00:00:00 ctl.sh
> > >  3115 ?        00:00:00 sleep
> > >  3115 ?        00:00:00 sleep
> > >  3116 ?        00:00:00 .memcached.bin
> > >  3116 ?        00:00:00 .memcached.bin
> > >
> > >
> > > As you can see, it is clear that the newer kernel is setting -17 by
> > > default, which in turn is causing the OOM killer loop.
> > >
> > > So I began to try and find what may have caused this problem by
> > > comparing the two sources...
> > >
> > > I checked the code for all references to 'oom_adj' and 'oom_adjust' in
> > > both code sets, but found no obvious differences:
> > > grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e oom_adjust -e
> > > oom_adj
> > >
> > > Then I checked for references to "-17" in all .c and .h files, and
> > > found a couple of matches, but only one obvious one:
> > > grep -R "\-17" . | grep -e ".c:" -e ".h:" -e "\-17" | wc -l
> > > ./include/linux/oom.h:#define OOM_DISABLE (-17)
> > >
> > > But again, a search for OOM_DISABLE came up with nothing obvious...
> > >
> > > In a last ditch attempt, I did a search for all references to 'oom'
> > > (case-insensitive) in both code bases, then compared the two:
> > >  root@annabelle [~/lol/linux-2.6.32.28] > grep -i -R "oom" . | sort -n
> > > > /tmp/annabelle.oom_adj
> > >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > grep -i -R
> > > "oom" . | sort -n > /tmp/vicky.oom_adj
> > >
> > > and this brought back (yet again) nothing obvious..
> > >
> > >
> > >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > md5sum
> > > ./include/linux/oom.h
> > > 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
> > >
> > >  root@annabelle [~/lol/linux-2.6.32.28] > md5sum ./include/linux/oom.h
> > > 2a32622f6cd38299fc2801d10a9a3ea8  ./include/linux/oom.h
> > >
> > >  root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] > md5sum
> > > ./mm/oom_kill.c
> > > 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
> > >
> > >  root@annabelle [~/lol/linux-2.6.32.28] > md5sum ./mm/oom_kill.c
> > > 1ef2c2bec19868d13ec66ec22033f10a  ./mm/oom_kill.c
> > >
> > >
> > >
> > > Could anyone please shed some light as to why the default oom_adj is
> > > set to -17 now (and where it is actually set)? From what I can tell,
> > > the fix for this issue will either be:
> > >
> > >   1. Allow OOM killer to override the decision of ignoring oom_adj ==
> > >      -17 if an unrecoverable loop is encountered.
> > >   2. Change the default back to 0.
> > >
> > > Again, my apologies if this bug report is slightly unorthodox, or
> > > doesn't follow usual procedure etc. I can assure you I have tried my
> > > absolute best to give all the necessary information though.
> > >
> > > Cal
> > >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"
> in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
>
>

--000e0cd286b423464f04a47c10fe
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div>@Kame</div><div>Thanks for the reply!<br><br></div><div>Both kernels u=
sed the same env/dist, but which slightly different packages.<br><br></div>=
<div>After many frustrating hours, I have pin pointed this down to a dodgy =
Debian package which appears to continue affecting the system, even after p=
urging. I&#39;m still yet to pin point the package down (I&#39;m doing seve=
ral reinstall tests, along with tripwire analysis after each reboot).</div>
<div><br></div><div>@Hiroyuki</div><div>Thank you for sending this to the r=
ight people!</div><div><br></div><div>@linux-mm</div><div>On a side note, w=
ould someone mind taking a few minutes to give a brief explanation as to ho=
w the default oom_adj is set, and under what conditions it is given -17 by =
default? Is this defined by the application? I looked through the kernel so=
urce, and noticed some of the code was defaulted to set oom_adj to OOM_DISA=
BLE (which is defined in the headers as -17).=A0</div>
<div><br></div><div>Assuming the debian problem is resolved, this might be =
another call for the oom-killer to be modified so that if it encounters the=
 unrecoverable loop, it ignores the -17 rule (with some exceptions, such as=
 kernel processes, and other critical things). If this is going to be a rel=
atively simple task, I wouldn&#39;t mind spending a few hours patching this=
?</div>
<div><br></div><div>Cal</div><div><br><div class=3D"gmail_quote">On Mon, Ma=
y 30, 2011 at 3:23 AM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt=
;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><br>
Thank you. memory cgroup and OOM troubles are handled in linux-mm.<br>
<div><div></div><div class=3D"h5"><br>
On Sun, 29 May 2011 23:24:07 +0100<br>
&quot;Cal Leeming [Simplicity Media Ltd]&quot; =A0&lt;<a href=3D"mailto:cal=
.leeming@simplicitymedialtd.co.uk">cal.leeming@simplicitymedialtd.co.uk</a>=
&gt; wrote:<br>
<br>
&gt; Some further logs:<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369927] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.369939]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399285] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.399296]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428690] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.428702]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487696] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.487708]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517023] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.517035]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546379] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:38 vicky kernel: [ 2283.546391]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310789] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.310804]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369918] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.369930]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399284] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.399296]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433634] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.433648]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463947] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.463959]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493439] redis-server=
<br>
&gt; invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D-17<br>
&gt; ./log/syslog:May 30 07:44:43 vicky kernel: [ 2288.493451]<br>
&gt; [&lt;ffffffff810b12b7&gt;] ? oom_kill_process+0x82/0x283<br>
&gt;<br>
&gt;<br>
<br>
</div></div>hmm, in short, applications has -17 oom_adj in default with 2.6=
.32.41 ?<br>
AFAIK, no kernel has such crazy settings as default..<br>
<br>
Does your 2 kernel uses the same environment/distribution ?<br>
<br>
Thanks,<br>
-Kame<br>
<div><div></div><div class=3D"h5"><br>
&gt; On 29/05/2011 22:50, Cal Leeming [Simplicity Media Ltd] wrote:<br>
&gt; &gt; =A0First of all, my apologies if I have submitted this problem to=
 the<br>
&gt; &gt; wrong place, spent 20 minutes trying to figure out where it needs=
 to<br>
&gt; &gt; be sent, and was still none the wiser.<br>
&gt; &gt;<br>
&gt; &gt; The problem is related to applying memory limitations within a cg=
roup.<br>
&gt; &gt; If the OOM killer kicks in, it gets stuck in a loop where it trie=
s to<br>
&gt; &gt; kill a process which has an oom_adj of -17. This causes an infini=
te<br>
&gt; &gt; loop, which in turn locks up the system.<br>
&gt; &gt;<br>
&gt; &gt; May 30 03:13:08 vicky kernel: [ 1578.117055] Memory cgroup out of=
<br>
&gt; &gt; memory: kill process 6016 (java) score 0 or a child<br>
&gt; &gt; May 30 03:13:08 vicky kernel: [ 1578.117154] Memory cgroup out of=
<br>
&gt; &gt; memory: kill process 6016 (java) score 0 or a child<br>
&gt; &gt; May 30 03:13:08 vicky kernel: [ 1578.117248] Memory cgroup out of=
<br>
&gt; &gt; memory: kill process 6016 (java) score 0 or a child<br>
&gt; &gt; May 30 03:13:08 vicky kernel: [ 1578.117343] Memory cgroup out of=
<br>
&gt; &gt; memory: kill process 6016 (java) score 0 or a child<br>
&gt; &gt; May 30 03:13:08 vicky kernel: [ 1578.117441] Memory cgroup out of=
<br>
&gt; &gt; memory: kill process 6016 (java) score 0 or a child<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; =A0root@vicky [/home/foxx] &gt; uname -a<br>
&gt; &gt; Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x=
86_64<br>
&gt; &gt; GNU/Linux<br>
&gt; &gt; (this happens on both the grsec patched and non patched 2.6.32.41=
 kernel)<br>
&gt; &gt;<br>
&gt; &gt; When this is encountered, the memory usage across the whole serve=
r is<br>
&gt; &gt; still within limits (not even hitting swap).<br>
&gt; &gt;<br>
&gt; &gt; The memory configuration for the cgroup/lxc is:<br>
&gt; &gt; lxc.cgroup.memory.limit_in_bytes =3D 3000M<br>
&gt; &gt; lxc.cgroup.memory.memsw.limit_in_bytes =3D 3128M<br>
&gt; &gt;<br>
&gt; &gt; Now, what is even more strange, is that when running under the<br=
>
&gt; &gt; 2.6.32.28 kernel (both patched and unpatched), this problem doesn=
&#39;t<br>
&gt; &gt; happen. However, there is a slight difference between the two ker=
nels.<br>
&gt; &gt; The 2.6.32.28 kernel gives a default of 0 in the /proc/X/oom_adj,=
<br>
&gt; &gt; where as the 2.6.32.41 gives a default of -17. I suspect this is =
the<br>
&gt; &gt; root cause of why it&#39;s showing in the later kernel, but not t=
he earlier.<br>
&gt; &gt;<br>
&gt; &gt; To test this theory, I started up the lxc on both servers, and th=
en<br>
&gt; &gt; ran a one liner which showed me all the processes with an oom_adj=
 of -17:<br>
&gt; &gt;<br>
&gt; &gt; (the below is the older/working kernel)<br>
&gt; &gt; root@courtney.internal [/mnt/encstore/lxc] &gt; uname -a<br>
&gt; &gt; Linux courtney.internal 2.6.32.28-grsec #3 SMP Fri Feb 18 16:09:0=
7 GMT<br>
&gt; &gt; 2011 x86_64 GNU/Linux<br>
&gt; &gt; root@courtney.internal [/mnt/encstore/lxc] &gt; for x in `find /p=
roc<br>
&gt; &gt; -iname &#39;oom_adj&#39; | xargs grep &quot;\-17&quot; =A0| awk -=
F &#39;/&#39; &#39;{print $3}&#39;` ; do<br>
&gt; &gt; ps -p $x --no-headers ; done<br>
&gt; &gt; grep: /proc/1411/task/1411/oom_adj: No such file or directory<br>
&gt; &gt; grep: /proc/1411/oom_adj: No such file or directory<br>
&gt; &gt; =A0 804 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A0 804 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; 25536 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; 25536 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; 31861 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; 31861 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; 32173 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; 32173 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; 32174 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; 32174 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt;<br>
&gt; &gt; (the below is the newer/broken kernel)<br>
&gt; &gt; =A0root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] &gt; una=
me -a<br>
&gt; &gt; Linux vicky 2.6.32.41-grsec #3 SMP Mon May 30 02:34:43 BST 2011 x=
86_64<br>
&gt; &gt; GNU/Linux<br>
&gt; &gt; =A0root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] &gt; for=
 x in<br>
&gt; &gt; `find /proc -iname &#39;oom_adj&#39; | xargs grep &quot;\-17&quot=
; =A0| awk -F &#39;/&#39; &#39;{print<br>
&gt; &gt; $3}&#39;` ; do ps -p $x --no-headers ; done<br>
&gt; &gt; grep: /proc/3118/task/3118/oom_adj: No such file or directory<br>
&gt; &gt; grep: /proc/3118/oom_adj: No such file or directory<br>
&gt; &gt; =A0 895 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A0 895 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A01091 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A01091 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A01092 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A01092 ? =A0 =A0 =A0 =A000:00:00 udevd<br>
&gt; &gt; =A02596 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02596 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02608 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02608 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02613 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02613 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A02614 pts/0 =A0 =A000:00:00 bash<br>
&gt; &gt; =A02614 pts/0 =A0 =A000:00:00 bash<br>
&gt; &gt; =A02620 pts/0 =A0 =A000:00:00 sudo<br>
&gt; &gt; =A02620 pts/0 =A0 =A000:00:00 sudo<br>
&gt; &gt; =A02621 pts/0 =A0 =A000:00:00 su<br>
&gt; &gt; =A02621 pts/0 =A0 =A000:00:00 su<br>
&gt; &gt; =A02622 pts/0 =A0 =A000:00:00 bash<br>
&gt; &gt; =A02622 pts/0 =A0 =A000:00:00 bash<br>
&gt; &gt; =A02685 ? =A0 =A0 =A0 =A000:00:00 lxc-start<br>
&gt; &gt; =A02685 ? =A0 =A0 =A0 =A000:00:00 lxc-start<br>
&gt; &gt; =A02699 ? =A0 =A0 =A0 =A000:00:00 init<br>
&gt; &gt; =A02699 ? =A0 =A0 =A0 =A000:00:00 init<br>
&gt; &gt; =A02939 ? =A0 =A0 =A0 =A000:00:00 rc<br>
&gt; &gt; =A02939 ? =A0 =A0 =A0 =A000:00:00 rc<br>
&gt; &gt; =A02942 ? =A0 =A0 =A0 =A000:00:00 startpar<br>
&gt; &gt; =A02942 ? =A0 =A0 =A0 =A000:00:00 startpar<br>
&gt; &gt; =A02964 ? =A0 =A0 =A0 =A000:00:00 rsyslogd<br>
&gt; &gt; =A02964 ? =A0 =A0 =A0 =A000:00:00 rsyslogd<br>
&gt; &gt; =A02964 ? =A0 =A0 =A0 =A000:00:00 rsyslogd<br>
&gt; &gt; =A02964 ? =A0 =A0 =A0 =A000:00:00 rsyslogd<br>
&gt; &gt; =A02980 ? =A0 =A0 =A0 =A000:00:00 startpar<br>
&gt; &gt; =A02980 ? =A0 =A0 =A0 =A000:00:00 startpar<br>
&gt; &gt; =A02981 ? =A0 =A0 =A0 =A000:00:00 ctlscript.sh<br>
&gt; &gt; =A02981 ? =A0 =A0 =A0 =A000:00:00 ctlscript.sh<br>
&gt; &gt; =A03016 ? =A0 =A0 =A0 =A000:00:00 cron<br>
&gt; &gt; =A03016 ? =A0 =A0 =A0 =A000:00:00 cron<br>
&gt; &gt; =A03025 ? =A0 =A0 =A0 =A000:00:00 mysqld_safe<br>
&gt; &gt; =A03025 ? =A0 =A0 =A0 =A000:00:00 mysqld_safe<br>
&gt; &gt; =A03032 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A03032 ? =A0 =A0 =A0 =A000:00:00 sshd<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03097 ? =A0 =A0 =A0 =A000:00:00 mysqld.bin<br>
&gt; &gt; =A03113 ? =A0 =A0 =A0 =A000:00:00 ctl.sh<br>
&gt; &gt; =A03113 ? =A0 =A0 =A0 =A000:00:00 ctl.sh<br>
&gt; &gt; =A03115 ? =A0 =A0 =A0 =A000:00:00 sleep<br>
&gt; &gt; =A03115 ? =A0 =A0 =A0 =A000:00:00 sleep<br>
&gt; &gt; =A03116 ? =A0 =A0 =A0 =A000:00:00 .memcached.bin<br>
&gt; &gt; =A03116 ? =A0 =A0 =A0 =A000:00:00 .memcached.bin<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; As you can see, it is clear that the newer kernel is setting -17 =
by<br>
&gt; &gt; default, which in turn is causing the OOM killer loop.<br>
&gt; &gt;<br>
&gt; &gt; So I began to try and find what may have caused this problem by<b=
r>
&gt; &gt; comparing the two sources...<br>
&gt; &gt;<br>
&gt; &gt; I checked the code for all references to &#39;oom_adj&#39; and &#=
39;oom_adjust&#39; in<br>
&gt; &gt; both code sets, but found no obvious differences:<br>
&gt; &gt; grep -R -e oom_adjust -e oom_adj . | sort | grep -R -e oom_adjust=
 -e<br>
&gt; &gt; oom_adj<br>
&gt; &gt;<br>
&gt; &gt; Then I checked for references to &quot;-17&quot; in all .c and .h=
 files, and<br>
&gt; &gt; found a couple of matches, but only one obvious one:<br>
&gt; &gt; grep -R &quot;\-17&quot; . | grep -e &quot;.c:&quot; -e &quot;.h:=
&quot; -e &quot;\-17&quot; | wc -l<br>
&gt; &gt; ./include/linux/oom.h:#define OOM_DISABLE (-17)<br>
&gt; &gt;<br>
&gt; &gt; But again, a search for OOM_DISABLE came up with nothing obvious.=
..<br>
&gt; &gt;<br>
&gt; &gt; In a last ditch attempt, I did a search for all references to &#3=
9;oom&#39;<br>
&gt; &gt; (case-insensitive) in both code bases, then compared the two:<br>
&gt; &gt; =A0root@annabelle [~/lol/linux-2.6.32.28] &gt; grep -i -R &quot;o=
om&quot; . | sort -n<br>
&gt; &gt; &gt; /tmp/annabelle.oom_adj<br>
&gt; &gt; =A0root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] &gt; gre=
p -i -R<br>
&gt; &gt; &quot;oom&quot; . | sort -n &gt; /tmp/vicky.oom_adj<br>
&gt; &gt;<br>
&gt; &gt; and this brought back (yet again) nothing obvious..<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; =A0root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] &gt; md5=
sum<br>
&gt; &gt; ./include/linux/oom.h<br>
&gt; &gt; 2a32622f6cd38299fc2801d10a9a3ea8 =A0./include/linux/oom.h<br>
&gt; &gt;<br>
&gt; &gt; =A0root@annabelle [~/lol/linux-2.6.32.28] &gt; md5sum ./include/l=
inux/oom.h<br>
&gt; &gt; 2a32622f6cd38299fc2801d10a9a3ea8 =A0./include/linux/oom.h<br>
&gt; &gt;<br>
&gt; &gt; =A0root@vicky [/mnt/encstore/ssd/kernel/linux-2.6.32.41] &gt; md5=
sum<br>
&gt; &gt; ./mm/oom_kill.c<br>
&gt; &gt; 1ef2c2bec19868d13ec66ec22033f10a =A0./mm/oom_kill.c<br>
&gt; &gt;<br>
&gt; &gt; =A0root@annabelle [~/lol/linux-2.6.32.28] &gt; md5sum ./mm/oom_ki=
ll.c<br>
&gt; &gt; 1ef2c2bec19868d13ec66ec22033f10a =A0./mm/oom_kill.c<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Could anyone please shed some light as to why the default oom_adj=
 is<br>
&gt; &gt; set to -17 now (and where it is actually set)? From what I can te=
ll,<br>
&gt; &gt; the fix for this issue will either be:<br>
&gt; &gt;<br>
&gt; &gt; =A0 1. Allow OOM killer to override the decision of ignoring oom_=
adj =3D=3D<br>
&gt; &gt; =A0 =A0 =A0-17 if an unrecoverable loop is encountered.<br>
&gt; &gt; =A0 2. Change the default back to 0.<br>
&gt; &gt;<br>
&gt; &gt; Again, my apologies if this bug report is slightly unorthodox, or=
<br>
&gt; &gt; doesn&#39;t follow usual procedure etc. I can assure you I have t=
ried my<br>
&gt; &gt; absolute best to give all the necessary information though.<br>
&gt; &gt;<br>
&gt; &gt; Cal<br>
&gt; &gt;<br>
&gt;<br>
</div></div>&gt; --<br>
&gt; To unsubscribe from this list: send the line &quot;unsubscribe linux-k=
ernel&quot; in<br>
&gt; the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">=
majordomo@vger.kernel.org</a><br>
&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-=
info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a>=
<br>
&gt; Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=
=3D"_blank">http://www.tux.org/lkml/</a><br>
&gt;<br>
<br>
</blockquote></div><br></div>

--000e0cd286b423464f04a47c10fe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
