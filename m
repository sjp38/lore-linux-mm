Date: Mon, 14 Oct 2002 17:24:22 -0400 (EDT)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.42-mm2 on small systems
In-Reply-To: <1969404353.1034580835@[10.10.2.3]>
Message-ID: <Pine.LNX.3.96.1021014171849.8102A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ed Tomlinson <tomlins@cam.org>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Oct 2002, Martin J. Bligh wrote:

>  
> > I have an old 486 with 64m and 512M of disk that I use as a serial 
> ...
> > with 2.5.42-mm2 it does not finish.  The machine is sort of usable 
> > while its runing and control C has no problem ending the program.  
> > I waited 11 hours for the spawnload test to complete - it was 
> 
> What does spawnload do (for those of us who don't have the inclination
> to go source diving)?

In this case a half scree of source diving is the best answer, it forks a
process which fork/exec's a shell, which either runs the builtin pwd or
/bin/pwd depending on what shell you have set. In most cases that's bash,
and uses the builtin. Does a bunch of process creation and cleanup, and
can generate some impressive contet switching.

    while (RunMe) {
        if (pid = fork()) {
            (void)wait();
            NumFork++;
        } else {
            // Do a 2nd level fork/exec a few times
            system("pwd >/dev/null");
            exit(0);
        }

I will say that I ran 41-mm2 and 41-mm2v (Con Kolivas' patch) just fine, I
can't get 5.42 anything to even build, it's looking for NLS and the config
has no NLS, unless I have a bad patch. I'm going to scan the list for
patches later, but that's my current eperience.

The README (choose text, Postscript or HTML) has a description of what
each test does. Or what I think it does.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
