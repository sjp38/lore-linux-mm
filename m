Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1C12F6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 01:08:19 -0400 (EDT)
Received: by bkbzt4 with SMTP id zt4so3082501bkb.14
        for <linux-mm@kvack.org>; Thu, 25 Aug 2011 22:08:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHKQLBH2d-DzzMfP9QOUmz6brT7BfPdwY6JfEUUYxzaTDTo=wg@mail.gmail.com>
References: <CAJ8eaTyeQj5_EAsCFDMmDs3faiVptuccmq3VJLjG-QnYG038=A@mail.gmail.com>
	<CAJ8eaTw=dKUNE8h-HD7RWxXHcTEuxJH4AfcOO44RSF7QdC5arQ@mail.gmail.com>
	<CAHKQLBH2d-DzzMfP9QOUmz6brT7BfPdwY6JfEUUYxzaTDTo=wg@mail.gmail.com>
Date: Fri, 26 Aug 2011 10:38:14 +0530
Message-ID: <CAJ8eaTxmZm6yw1YWhdfaxwuf0mF+sOfX6RUPfcu-qiHYu+D4CA@mail.gmail.com>
Subject: Re: Kernel panic in 2.6.35.12 kernel
From: naveen yadav <yad.naveen@gmail.com>
Content-Type: multipart/mixed; boundary=0015174c185c5a401004ab6188ee
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Chen <schen@mvista.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm <linux-mm@kvack.org>

--0015174c185c5a401004ab6188ee
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Steve.

Pls find attached code for stress application. The test code is very
simple. Just alloc memory.
we got this issue on embedded Target.
After analysis we found that most of task(stress_application) is in D
for uninterruptible sleep.
application           state

stress                  x
stress                  D
stress                  x
stress                  D
stress                  x
stress                  D
stress                  x
sleep                   D

Thanks




On Thu, Aug 25, 2011 at 7:27 PM, Steve Chen <schen@mvista.com> wrote:
> On Thu, Aug 25, 2011 at 1:06 AM, naveen yadav <yad.naveen@gmail.com> wrot=
e:
>> I am paste only small crash log due to size problem.
>>
>>
>>
>>
>>> Hi All,
>>>
>>> We are running one malloc testprogram using below script.
>>>
>>> while true
>>> do
>>> ./stress &
>>> sleep 1
>>> done
>>>
>>>
>>>
>>>
>>> After 10-15 min we observe following crash in kernel
>>>
>>>
>>> =A0Kernel panic - not syncing: Out of memory and no killable processes.=
..
>>>
>>> attaching log also.
>>>
>>> Thanks
>>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>
>>
>
> Can you share the code in ./stress?
>
> Thanks,
>
> Steve
>

--0015174c185c5a401004ab6188ee
Content-Type: text/x-csrc; charset=US-ASCII; name="stress_application.c"
Content-Disposition: attachment; filename="stress_application.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_grsp8d9i0

I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RkbGliLmg+DQojaW5jbHVkZSA8c3RyaW5n
Lmg+DQojaW5jbHVkZSA8cHRocmVhZC5oPg0KI2luY2x1ZGUgPHVuaXN0ZC5oPg0KDQojZGVmaW5l
IEFMTE9DX0JZVEUgNTEyKjEwMjQNCiNkZWZpbmUgQ09VTlQgNTAwDQoNCnZvaWQgKmFsbG9jX2Z1
bmN0aW9uKCB2b2lkICpwdHIgKTsNCg0KDQppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqYXJndltd
KQ0Kew0KCXB0aHJlYWRfdCB0aHJlYWQxLCB0aHJlYWQyOw0KCWNoYXIgKm1lc3NhZ2UxID0gIlRo
cmVhZCAxIjsNCg0KCWludCAgaXJldDEsIGlyZXQyOw0KDQoJaXJldDEgPSBwdGhyZWFkX2NyZWF0
ZSggJnRocmVhZDEsIE5VTEwsIGFsbG9jX2Z1bmN0aW9uLCAodm9pZCopIG1lc3NhZ2UxKTsNCg0K
DQoJcHRocmVhZF9qb2luKCB0aHJlYWQxLCBOVUxMKTsNCg0KDQoJcHJpbnRmKCJUaHJlYWQgMSBy
ZXR1cm5zOiAlZFxuIixpcmV0MSk7DQoNCglleGl0KDApOw0KDQp9DQoNCnZvaWQgKmFsbG9jX2Z1
bmN0aW9uKCB2b2lkICpwdHIgKQ0Kew0KCWNoYXIgKm1lc3NhZ2U7DQoJbWVzc2FnZSA9IChjaGFy
ICopIHB0cjsNCgl2b2lkICpteWJsb2NrW0NPVU5UXTsNCglpbnQgaT0gMCxqPTA7DQoJaW50IGZy
ZWVkPTA7DQoJcHJpbnRmKCJtZXNzYWdlX2FsbG9jICBcbiIpOw0KCXdoaWxlKDEpDQoJew0KCQlt
ZW1zZXQobXlibG9jaywwLHNpemVvZihteWJsb2NrKSk7DQoJCXByaW50ZigibWVzc2FnZV9hbGxv
YyAlcyBcbiIsbWVzc2FnZSk7DQoJCWZvcihpPTA7aTwgQ09VTlQgO2krKykNCgkJew0KCQkJbXli
bG9ja1tpXSA9ICh2b2lkICopIG1hbGxvYyhBTExPQ19CWVRFKTsNCgkJCWlmICghbXlibG9ja1tp
XSkNCgkJCXsNCgkJCQlwcmludGYoIk5vIG1lbW9yeSBmb3IgYWxsb2NhdGluZzogZnJlZWluZyBc
biIpOw0KCQkJCXByaW50ZigiT09NIG1heSBraWxsIE1FIFxuIik7DQoJCQkJZm9yKGo9MDtqIDwg
aTtqKyspDQoJCQkJew0KCQkJCQlmcmVlZCA9IDE7DQoJCQkJCWZyZWUobXlibG9ja1tqXSk7DQoJ
CQkJCXByaW50ZigiQ3VycmVudGx5IGZyZWVpbmcgJWQgKiAlZCBCeXRlcyBcbiIsaixBTExPQ19C
WVRFKTsNCgkJCQl9DQoJCQkJYnJlYWs7DQoJCQl9DQoJCQltZW1zZXQobXlibG9ja1tpXSwxLCBB
TExPQ19CWVRFKTsNCgkJCS8vCXByaW50ZigiQ3VycmVudGx5IGFsbG9jYXRpbmcgJWQgKiAlZCBC
eXRlcyBcbiIsaSxBTExPQ19CWVRFKTsNCgkJfQ0KCQlzbGVlcCgxKTsNCiNpZiAxDQoJCWlmKCFm
cmVlZCkgew0KCQkJZm9yKGk9MDtpPCBDT1VOVDtpKyspDQoJCQl7DQoJCQkJZnJlZShteWJsb2Nr
W2ldKTsNCgkJCQkvLwlwcmludGYoIkN1cnJlbnRseSBmcmVlaW5nICVkICogJWQgQnl0ZXMgXG4i
LGksQUxMT0NfQllURSk7DQoJCQl9DQoJCX0NCgkJc2xlZXAoMSk7DQojZW5kaWYNCgl9DQp9DQoN
Cg==
--0015174c185c5a401004ab6188ee--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
