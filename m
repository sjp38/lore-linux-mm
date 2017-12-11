Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72CA06B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 22:48:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t9so11928039pgu.1
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 19:48:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w69si10314679pfd.289.2017.12.10.19.48.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 19:48:34 -0800 (PST)
Message-Id: <201712110348.vBB3mSFZ068689@www262.sakura.ne.jp>
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Mon, 11 Dec 2017 12:48:28 +0900
References: <201712110014.vBB0ENwU088603@www262.sakura.ne.jp> <1512963298.23718.15.camel@gmail.com>
In-Reply-To: <1512963298.23718.15.camel@gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail <mikhail.v.gavrilov@gmail.com>
Cc: mhocko@kernel.org, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

mikhail wrote:
> > > netconsole works only within local network? destination ip may be from
> > > another network?
> > 
> > netconsole can work with another network.
> > 
> > (step 1) Verify that UDP packets are reachable. You can test with
> > 
> >          # echo test > /dev/udp/213.136.82.171/6666
> > 
> >          if you are using bash.
> 
> After this on remote machine was created folder with name of router
> external ip address.
> Inside this folder was places one file with name of current day. This
> file has size 0 of bytes and not contain "test" message inside.
> That is how it should be?

The message should be written to the log file. If not written, UDP packets
are dropped somewhere. You need to solve this problem first.

> 
> > 
> > (step 2) Verify that you specified gateway's MAC address rather than
> >          target host's MAC address. "ff:ff:ff:ff:ff:ff" suggests that
> >          netconsole is unable to resolve correct MAC address.
> > 
> 
> I am not was specified MAC address when launch netconsole. The address
> "ff:ff:ff:ff:ff:ff" was settled by default.
> Anyway does it matter for remote machine placed behind router?
> Ok, I also setted right MAC address for remote machine. But nothing is
> changed.

If remote machine is in a different network segment, you need to specify
gateway's MAC address rather than remote machine's MAC address. For more
information about netconsole, please see
https://www.kernel.org/doc/Documentation/networking/netconsole.txt .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
