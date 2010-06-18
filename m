Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 645D66B01B7
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 04:11:10 -0400 (EDT)
Received: by qyk4 with SMTP id 4so1749661qyk.14
        for <linux-mm@kvack.org>; Fri, 18 Jun 2010 01:11:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100617173604.GB28055@tux>
References: <AANLkTikaH5sYv-pa6OEIPCofF8RAbi7F3nTdWqEXWr8J@mail.gmail.com>
	<20100617173604.GB28055@tux>
Date: Fri, 18 Jun 2010 13:41:07 +0530
Message-ID: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
Subject: Re: Probable Bug (or configuration error) in kmemleak
From: Sankar P <sankar.curiosity@gmail.com>
Content-Type: multipart/mixed; boundary=00c09f89935b43669a0489497fed
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Cc: "rnagarajan@novell.com" <rnagarajan@novell.com>, "teheo@novell.com" <teheo@novell.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Luis Rodriguez <Luis.Rodriguez@atheros.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--00c09f89935b43669a0489497fed
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 17, 2010 at 11:06 PM, Luis R. Rodriguez
<lrodriguez@atheros.com> wrote:
> On Thu, Jun 17, 2010 at 02:21:56AM -0700, Sankar P wrote:
>> Hi,
>>
>> I wanted to detect memory leaks in one of my kernel modules. So I
>> built Linus' tree =A0with the following config options enabled (on top
>> of make defconfig)
>>
>> CONFIG_DEBUG_KMEMLEAK=3Dy
>> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=3D400
>> CONFIG_DEBUG_KMEMLEAK_TEST=3Dy
>>
>> If I boot with this kernel, debugfs is automatically mounted. But I do
>> not have the file:
>>
>> /sys/kernel/debug/kmemleak
>>
>> created at all. There are other files like kprobes in the mounted
>> /sys/kernel/debug directory btw. So I am not able to detect any of the
>> memory leaks. Is there anything I am doing wrong or missing (or) is
>> this a bug in kmemleak ?
>>
>> Please let me know your suggestions to fix this and get memory leaks
>> reporting working. Thanks.
>>
>> The full .config file is also attached with this mail. Sorry for the
>> attachment, I did not want to paste 5k lines in the mail. Sorry if it
>> is wrong.
>
>
> This is odd.. Do you see this message on your kernel ring buffer?
>
> Failed to create the debugfs kmemleak file
>

I dont see such an error in the dmesg output. But I got another
interesting error:

[    0.000000] kmemleak: Early log buffer exceeded, please increase
DEBUG_KMEMLEAK_EARLY_LOG_SIZE
[    0.000000] kmemleak: Kernel memory leak detector disabled

But after that also, I see some other lines like:

[    0.511641] kmemleak: vmalloc(64) =3D f7857000
[    0.511645] kmemleak: vmalloc(64) =3D f785a000

The variable  DEBUG_KMEMLEAK_EARLY_LOG_SIZE was set to 400 by default.
I changed it to 4000 and then 40000 (may be should try < 32567 ?) but
still I get the same error message and the file
/sys/kernel/debug/kmem* is never created at all.

Attached is the output of : dmesg | grep -i kmemleak

--=20
Sankar P
http://psankar.blogspot.com

--00c09f89935b43669a0489497fed
Content-Type: application/octet-stream; name=psankar-dmsg
Content-Disposition: attachment; filename=psankar-dmsg
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gakqo4xs0

WyAgICAwLjAwMDAwMF0gTGludXggdmVyc2lvbiAyLjYuMzIuMTNzbGUta21lbWxlYWsgKGdlZWtv
QGJ1aWxkaG9zdCkgKGdjYyB2ZXJzaW9uIDQuMy40IFtnY2MtNF8zLWJyYW5jaCByZXZpc2lvbiAx
NTI5NzNdIChTVVNFIExpbnV4KSApICMxIFNNUCBUaHUgSnVuIDE3IDA0OjE3OjAyIElTVCAyMDEw
ClsgICAgMC4wMDAwMDBdIGttZW1sZWFrOiBFYXJseSBsb2cgYnVmZmVyIGV4Y2VlZGVkLCBwbGVh
c2UgaW5jcmVhc2UgREVCVUdfS01FTUxFQUtfRUFSTFlfTE9HX1NJWkUKWyAgICAwLjAwMDAwMF0g
a21lbWxlYWs6IEtlcm5lbCBtZW1vcnkgbGVhayBkZXRlY3RvciBkaXNhYmxlZApbICAgIDAuNTEx
NTg1XSBLbWVtbGVhayB0ZXN0aW5nClsgICAgMC41MTE1ODhdIGttZW1sZWFrOiBrbWFsbG9jKDMy
KSA9IGY0NDg3NmUwClsgICAgMC41MTE1OTFdIGttZW1sZWFrOiBrbWFsbG9jKDMyKSA9IGY0NDg3
NmE4ClsgICAgMC41MTE1OTVdIGttZW1sZWFrOiBrbWFsbG9jKDEwMjQpID0gZjQ3Yzc0ZjgKWyAg
ICAwLjUxMTU5OV0ga21lbWxlYWs6IGttYWxsb2MoMTAyNCkgPSBmNDdjNzBlMApbICAgIDAuNTEx
NjA0XSBrbWVtbGVhazoga21hbGxvYygyMDQ4KSA9IGY0NDBiMDYwClsgICAgMC41MTE2MDldIGtt
ZW1sZWFrOiBrbWFsbG9jKDIwNDgpID0gZjQ0MGE4NDgKWyAgICAwLjUxMTYyMF0ga21lbWxlYWs6
IGttYWxsb2MoNDA5NikgPSBmNDdiNTAwMApbICAgIDAuNTExNjMwXSBrbWVtbGVhazoga21hbGxv
Yyg0MDk2KSA9IGY0N2I2MDAwClsgICAgMC41MTE2NDFdIGttZW1sZWFrOiB2bWFsbG9jKDY0KSA9
IGY3ODU3MDAwClsgICAgMC41MTE2NDVdIGttZW1sZWFrOiB2bWFsbG9jKDY0KSA9IGY3ODVhMDAw
ClsgICAgMC41MTE2NDldIGttZW1sZWFrOiB2bWFsbG9jKDY0KSA9IGY3ODVkMDAwClsgICAgMC41
MTE2NTNdIGttZW1sZWFrOiB2bWFsbG9jKDY0KSA9IGY3ODYwMDAwClsgICAgMC41MTE2NTddIGtt
ZW1sZWFrOiB2bWFsbG9jKDY0KSA9IGY3ODYzMDAwClsgICAgMC41MTE2NjBdIGttZW1sZWFrOiBr
bWFsbG9jKHNpemVvZigqZWxlbSkpID0gZjQ3YjNhMzgKWyAgICAwLjUxMTY2M10ga21lbWxlYWs6
IGttYWxsb2Moc2l6ZW9mKCplbGVtKSkgPSBmNDdiMzkyMApbICAgIDAuNTExNjY2XSBrbWVtbGVh
azoga21hbGxvYyhzaXplb2YoKmVsZW0pKSA9IGY0N2IzODA4ClsgICAgMC41MTE2NjldIGttZW1s
ZWFrOiBrbWFsbG9jKHNpemVvZigqZWxlbSkpID0gZjQ3YjM2ZjAKWyAgICAwLjUxMTY3Ml0ga21l
bWxlYWs6IGttYWxsb2Moc2l6ZW9mKCplbGVtKSkgPSBmNDdiMzVkOApbICAgIDAuNTExNjc1XSBr
bWVtbGVhazoga21hbGxvYyhzaXplb2YoKmVsZW0pKSA9IGY0N2IzNGMwClsgICAgMC41MTE2Nzhd
IGttZW1sZWFrOiBrbWFsbG9jKHNpemVvZigqZWxlbSkpID0gZjQ3YjMzYTgKWyAgICAwLjUxMTY4
MV0ga21lbWxlYWs6IGttYWxsb2Moc2l6ZW9mKCplbGVtKSkgPSBmNDdiMzI5MApbICAgIDAuNTEx
Njg0XSBrbWVtbGVhazoga21hbGxvYyhzaXplb2YoKmVsZW0pKSA9IGY0N2IzMTc4ClsgICAgMC41
MTE2ODddIGttZW1sZWFrOiBrbWFsbG9jKHNpemVvZigqZWxlbSkpID0gZjQ3YjMwNjAKWyAgICAw
LjUxMTY5M10ga21lbWxlYWs6IGttYWxsb2MoMTI5KSA9IGY0N2I3ZTk4ClsgICAgMC41MTE2OTZd
IGttZW1sZWFrOiBrbWFsbG9jKDEyOSkgPSBmNDdiN2Q4MApbICAgIDIuMDU2NDMzXSB1c2IgdXNi
MTogTWFudWZhY3R1cmVyOiBMaW51eCAyLjYuMzIuMTNzbGUta21lbWxlYWsgZWhjaV9oY2QKWyAg
ICAyLjA5NzI4MF0gdXNiIHVzYjI6IE1hbnVmYWN0dXJlcjogTGludXggMi42LjMyLjEzc2xlLWtt
ZW1sZWFrIGVoY2lfaGNkClsgICAgMi4xMTc0MTNdIHVzYiB1c2IzOiBNYW51ZmFjdHVyZXI6IExp
bnV4IDIuNi4zMi4xM3NsZS1rbWVtbGVhayB1aGNpX2hjZApbICAgIDIuMTE4MzUzXSB1c2IgdXNi
NDogTWFudWZhY3R1cmVyOiBMaW51eCAyLjYuMzIuMTNzbGUta21lbWxlYWsgdWhjaV9oY2QKWyAg
ICAyLjExOTIyOV0gdXNiIHVzYjU6IE1hbnVmYWN0dXJlcjogTGludXggMi42LjMyLjEzc2xlLWtt
ZW1sZWFrIHVoY2lfaGNkClsgICAgMi4xMjAwOThdIHVzYiB1c2I2OiBNYW51ZmFjdHVyZXI6IExp
bnV4IDIuNi4zMi4xM3NsZS1rbWVtbGVhayB1aGNpX2hjZApbICAgIDIuMTIwOTU3XSB1c2IgdXNi
NzogTWFudWZhY3R1cmVyOiBMaW51eCAyLjYuMzIuMTNzbGUta21lbWxlYWsgdWhjaV9oY2QKWyAg
ICAyLjEyMTgyMV0gdXNiIHVzYjg6IE1hbnVmYWN0dXJlcjogTGludXggMi42LjMyLjEzc2xlLWtt
ZW1sZWFrIHVoY2lfaGNkCg==
--00c09f89935b43669a0489497fed--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
