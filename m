Received: from [129.179.161.11] by ns1.cdc.com with ESMTP for linux-mm@kvack.org; Thu, 30 Aug 2001 17:43:34 -0500
Message-Id: <3B8EC0B8.3000504@syntegra.com>
Date: Thu, 30 Aug 2001 17:39:52 -0500
From: Andrew Kay <Andrew.J.Kay@syntegra.com>
Subject: Re: kernel: __alloc_pages: 1-order allocation failed
References: <Pine.LNX.4.21.0108271928250.7385-100000@freak.distro.conectiva> <20010829175351Z16158-32383+2308@humbolt.nl.linux.org> <3B8E4CB7.4010509@syntegra.com> <20010830221315Z16034-32383+2530@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> Ouch.  I don't have any particular difficulty figuring out where the failures
> are coming from - I have some ideas on what to do about them, but those lock-ups
> don't make sense given the information you've supplied.  Would you try this on
> 2.4.9-ac4 please?
> 
> Also, the backtrace now makes sense, but just for the first 6 entries.  Now that
> you have your System.map properly linked, klogd should be decoding the backtrace.
> What version is your klogd?  Is your network code in modules or compiled in?
> 
> Could you supply a ps -aux that shows your hung processes?  Even better,
> backtrace with SysReq.
> 


I am running the stock klogd (1.4.0) from the redhat 7.1 install.  I'll 
give it a try with the 2.4.9-ac4 tomorrow.  The output you saw is from a 
  mostly static kernel (except for reiserfs).  Ps -aux shows a bit of 
output, but remember that it hangs after encountering the error... Mhsqd 
is one of our products.  I strongly suspect that the hung process is 
SMTPserver, which isn't shown

USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0  1408   80 ?        S    Aug29   0:03 init [3]
root         2  0.0  0.0     0    0 ?        SW   Aug29   0:00 [keventd]
root         3  0.0  0.0     0    0 ?        SWN  Aug29   0:01 
[ksoftirqd_CPU0]
root         4  0.1  0.0     0    0 ?        SW   Aug29   2:01 [kswapd]
root         5  0.0  0.0     0    0 ?        SW   Aug29   0:00 [kreclaimd]
root         6  0.0  0.0     0    0 ?        SW   Aug29   0:00 [bdflush]
root         7  0.0  0.0     0    0 ?        SW   Aug29   0:01 [kupdated]
root         8  0.0  0.0     0    0 ?        SW   Aug29   0:00 [i2oevtd]
root         9  0.0  0.0     0    0 ?        SW   Aug29   0:00 [i2oblock]
rpc        443  0.0  0.0  1552  236 ?        S    Aug29   0:01 portmap
rpcuser    458  0.0  0.0  1640    0 ?        SW   Aug29   0:00 rpc.statd
root       553  0.0  0.0 18028  288 ?        S    Aug29   0:00 ypbind
root       554  0.0  0.0 18028  288 ?        S    Aug29   0:00 ypbind
root       555  0.0  0.0 18028  288 ?        S    Aug29   0:00 ypbind
root       557  0.0  0.0 18028  288 ?        S    Aug29   0:00 ypbind
root       604  0.0  0.0  1520   48 ?        S    Aug29   0:00 
/usr/sbin/automount --timeout 60 /misc file /etc/auto.misc
root       630  0.0  0.0  1604   48 ?        S    Aug29   0:00 
/usr/sbin/automount /idisk yp auto.idisk
daemon     648  0.0  0.0  1440   36 ?        S    Aug29   0:00 /usr/sbin/atd
root       665  0.0  0.0  2624  596 ?        S    Aug29   0:00 
/usr/sbin/sshd
root       686  0.0  0.0  1628  128 ?        S    Aug29   0:00 crond
xfs        714  0.0  0.0  4368   52 ?        S    Aug29   0:00 xfs 
-droppriv -daemon
root       739  0.0  0.0  1380    4 tty1     S    Aug29   0:00 
/sbin/mingetty tty1
root       740  0.0  0.0  1380    0 tty2     SW   Aug29   0:00 
/sbin/mingetty tty2
root       741  0.0  0.0  1380    0 tty3     SW   Aug29   0:00 
/sbin/mingetty tty3
root       742  0.0  0.0  1380    0 tty4     SW   Aug29   0:00 
/sbin/mingetty tty4
root       743  0.0  0.0  1380    0 tty5     SW   Aug29   0:00 
/sbin/mingetty tty5
root       744  0.0  0.0  1380    0 tty6     SW   Aug29   0:00 
/sbin/mingetty tty6
root       826  0.0  0.0     0    0 ?        SW   Aug29   0:00 [kreiserfsd]
root       847  0.0  0.0  1468  164 ?        S    Aug29   0:02 syslogd -m 0
root       853  0.0  0.0  1468    4 ?        S    Aug29   0:00 klogd -2
root       858  0.0  0.0     0    0 ?        SW   Aug29   1:24 [rpciod]
root       859  0.0  0.0     0    0 ?        SW   Aug29   0:00 [lockd]
root       908  0.0  0.0  2892  128 ?        S    Aug29   0:47 
/var/process/exec/mhsqd -s 1000

-Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
