Received: by an-out-0708.google.com with SMTP id d33so401012and
        for <linux-mm@kvack.org>; Mon, 04 Jun 2007 04:48:05 -0700 (PDT)
Message-ID: <2c09dd780706040448g792512a8nc62712097d62cc92@mail.gmail.com>
Date: Mon, 4 Jun 2007 17:18:05 +0530
From: "manjunath k" <kmanjunat@gmail.com>
Subject: /proc/pid/maps output
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

 Ive been verifying the /proc/pid/maps output which looks as below,

# cat /proc/<pid>/maps

003f2000-003f3000 r-xp 003f2000 00:00 0
007e6000-007fb000 r-xp 00000000 08:03 14833414   /lib/ld-2.3.6.so
007fc000-007fd000 r--p 00015000 08:03 14833414   /lib/ld-2.3.6.so
007fd000-007fe000 rw-p 00016000 08:03 14833414   /lib/ld-2.3.6.so
00804000-00928000 r-xp 00000000 08:03 14928618   /lib/tls/libc-2.3.6.so
00928000-00929000 ---p 00124000 08:03 14928618   /lib/tls/libc-2.3.6.so
00929000-0092b000 r--p 00124000 08:03 14928618   /lib/tls/libc-2.3.6.so
0092b000-0092d000 rw-p 00126000 08:03 14928618   /lib/tls/libc-2.3.6.so
0092d000-0092f000 rw-p 0092d000 00:00 0
08048000-0804c000 r-xp 00000000 08:03 5095452    /bin/cat
0804c000-0804d000 rw-p 00003000 08:03 5095452    /bin/cat
0a01c000-0a03d000 rw-p 0a01c000 00:00 0          [heap]
b7d21000-b7f21000 r--p 00000000 08:03 25480659   /usr/lib/locale/locale-archive
b7f21000-b7f23000 rw-p b7f21000 00:00 0
bf81d000-bf832000 rw-p bf81d000 00:00 0          [stack]

In the above output the last column displays the name of libraries and
executables,
but in columns 1, 9 and 14 there is no name displayed, can anyone give
some information about this, regarding what does it correspond to.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
