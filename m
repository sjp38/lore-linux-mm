Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D92D86B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:34:42 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h26-v6so10272265itf.4
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:34:42 -0700 (PDT)
Received: from sonic311-22.consmr.mail.ne1.yahoo.com (sonic311-22.consmr.mail.ne1.yahoo.com. [66.163.188.203])
        by mx.google.com with ESMTPS id y77-v6si2292708iof.72.2018.07.20.14.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 14:34:41 -0700 (PDT)
Date: Fri, 20 Jul 2018 21:34:38 +0000 (UTC)
From: David Frank <david_frank95@yahoo.com>
Message-ID: <289656.55439.1532122478212@mail.yahoo.com>
In-Reply-To: <1835984892.475561.1532108339625@mail.yahoo.com>
References: <1835984892.475561.1532108339625.ref@mail.yahoo.com> <1835984892.475561.1532108339625@mail.yahoo.com>
Subject: memcpy seg fault with mmaped address
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_55438_428776891.1532122478211"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-mm <linux-mm@kvack.org>

------=_Part_55438_428776891.1532122478211
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

=20

 Hi,=20
I'm memcpy data into mmaped address with 2GB file, after a few files, it wo=
uld fault with the following stack dump:
received signal SIGSEGV, Segmentation fault.[Switching to Thread 0x7ffff5e9=
5700 (LWP 3028)]
__memmove_avx_unaligned_erms ()
=C2=A0=C2=A0=C2=A0 at ../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erm=
s.S:494
494=C2=A0=C2=A0=C2=A0 ../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erm=
s.S: No such
file or directory.
(gdb) bt
#0=C2=A0 __memmove_avx_unaligned_erms ()
=C2=A0=C2=A0=C2=A0 at ../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erm=
s.S:494


Any idea?
Thanks,
David
 =20
------=_Part_55438_428776891.1532122478211
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<html><head></head><body><div style="font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:16px;"><div style="font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:16px;"><div></div>
        <div><br></div><div id="ydpc4b12af0yahoo_quoted_2998272837" class="ydpc4b12af0yahoo_quoted"><div style="font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:13px;color:#26282a;"><div><br></div>
                <div><div id="ydpc4b12af0yiv4069575967"><div><div style="font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px;"><div style="font-family:Helvetica Neue, Helvetica, Arial, sans-serif;font-size:13px;"><div><span>Hi, <br></span></div><div><span>I'm memcpy data into mmaped address with 2GB file, after a few files, it would fault with the following stack dump:</span></div><div><span><br></span></div><div><span>received signal SIGSEGV, Segmentation fault.</span></div><span>[Switching to Thread 
0x7ffff5e95700 (LWP 3028)]<br>__memmove_avx_unaligned_erms ()<br>&nbsp;&nbsp;&nbsp; at 
../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erms.S:494<br>494&nbsp;&nbsp;&nbsp; 
../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erms.S: No such<br>file or 
directory.<br>(gdb) bt<br>#0&nbsp; __memmove_avx_unaligned_erms ()<br></span><div><span>&nbsp;&nbsp;&nbsp; at 
../sysdeps/x86_64/multiarch/memmove-vec-unaligned-erms.S:494</span></div><div><span></span><br></div><div><br></div><div><br></div><div>Any idea?</div><div><br></div><div>Thanks,</div><div><br></div><div>David<br></div></div></div></div></div></div>
            </div>
        </div></div></div></body></html>
------=_Part_55438_428776891.1532122478211--
