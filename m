Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9B45900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 07:29:50 -0400 (EDT)
Received: by qgf75 with SMTP id 75so26473712qgf.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 04:29:50 -0700 (PDT)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id 134si7189683qhu.76.2015.06.05.04.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 04:29:50 -0700 (PDT)
Received: by qcnj1 with SMTP id j1so2624816qcn.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 04:29:50 -0700 (PDT)
Message-ID: <557187F9.8020301@gmail.com>
Date: Fri, 05 Jun 2015 07:28:57 -0400
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: split out forced OOM killer
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms010302080500080207080006"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms010302080500080207080006
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-06-04 18:59, David Rientjes wrote:
> On Tue, 2 Jun 2015, Michal Hocko wrote:
>
>> OOM killer might be triggered externally via sysrq+f. This is supposed=

>> to kill a task no matter what e.g. a task is selected even though ther=
e
>> is an OOM victim on the way to exit. This is a big hammer for an admin=

>> to help to resolve a memory short condition when the system is not abl=
e
>> to cope with it on its own in a reasonable time frame (e.g. when the
>> system is trashing or the OOM killer cannot make sufficient progress).=

>>
>> The forced OOM killing is currently wired into out_of_memory()
>> call which is kind of ugly because generic out_of_memory path
>> has to deal with configuration settings and heuristics which
>> are completely irrelevant to the forced OOM killer (e.g.
>> sysctl_oom_kill_allocating_task or OOM killer prevention for already
>> dying tasks). Some of those will not apply to sysrq because the handle=
r
>> runs from the worker context.
>> check_panic_on_oom on the other hand will work and that is kind of
>> unexpected because sysrq+f should be usable to kill a mem hog whether
>> the global OOM policy is to panic or not.
>> It also doesn't make much sense to panic the system when no task canno=
t
>> be killed because admin has a separate sysrq for that purpose.
>>
>> Let's pull forced OOM killer code out into a separate function
>> (force_out_of_memory) which is really trivial now. Also extract the co=
re
>> of oom_kill_process into __oom_kill_process which doesn't do any
>> OOM prevention heuristics.
>> As a bonus we can clearly state that this is a forced OOM killer in th=
e
>> OOM message which is helpful to distinguish it from the regular OOM
>> killer.
>>
>
> I'm not sure what the benefit of this is, and it's adding more code.
> Having multiple pathways and requirements, such as constrained_alloc(),=
 to
> oom kill a process isn't any clearer, in my opinion.  It also isn't
> intended to be optimized since the oom killer called from the page
> allocator and from sysrq aren't fastpaths.  To me, this seems like only=
 a
> source code level change and doesn't make anything more clear but rathe=
r
> adds more code and obfuscates the entry path.

At the very least, it does make the semantics of sysrq-f much nicer for=20
admins (especially the bit where it ignores the panic_on_oom setting, if =

the admin wants the system to panic, he'll use sysrq-c).  There have=20
been times I've had to hit sysrq-f multiple times to get to actually=20
kill anything, and this looks to me like it would eliminate that rather=20
annoying issue as well.



--------------ms010302080500080207080006
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGuDCC
BrQwggScoAMCAQICAxBuVTANBgkqhkiG9w0BAQ0FADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0xNTAz
MjUxOTM0MzhaFw0xNTA5MjExOTM0MzhaMGMxGDAWBgNVBAMTD0NBY2VydCBXb1QgVXNlcjEj
MCEGCSqGSIb3DQEJARYUYWhmZXJyb2luN0BnbWFpbC5jb20xIjAgBgkqhkiG9w0BCQEWE2Fo
ZW1tZWxnQG9oaW9ndC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCdD/zW
2rRAFCLnDfXpWxU1+ODqRVUgzHvrRO7ADUxRo1CBDc3JSX5TIW2OGmQ3DAKGOACp8Z0sgxMc
B05tzAZ/M7m4jajVrwwdVCdrwVGxTdAai7Kwg4ZCVfyMVhcwo8R2eW3QahBx34G0RKumK9sZ
ZQSQ+zULAzpY6uz7T1sAk/erMoivRXF6u8WvOsLkOD1F/Xyv1ZccSUG5YeDgZgc0nZUBvyIp
zXSHjgWerFkrxEM3y2z/Ff3eL1sgGYecV/I1F+I5S01V7Kclt/qRW10c/4JEGRcI1FmrJBPu
BtMYPbg/3Y9LZROYN+mVIFxZxOfrmjfFZ96xt/TaMXo8vcEKtWcNEjhGBjEbfMUEm4aq8ygQ
4MuEcpJc8DJCHBkg2KBk13DkbU2qNepTD6Uip1C+g+KMr0nd6KOJqSH27ZuNY4xqV4hIxFHp
ex0zY7mq6fV2o6sKBGQzRdI20FDYmNjsLJwjH6qJ8laxFphZnPRpBThmu0AjuBWE72GnI1oA
aO+bs92MQGJernt7hByCnDO82W/ykbVz+Ge3Sax8NY0m2Xdvp6WFDY/PjD9CdaJ9nwQGsUSa
N54lrZ2qMTeCI9Vauwf6U69BA42xgk65VvxvTNqji+tZ4aZbarZ7el2/QDHOb/rRwlCFplS/
z4l1f1nOrE6bnDl5RBJyW3zi74P6GwIDAQABo4IBWTCCAVUwDAYDVR0TAQH/BAIwADBWBglg
hkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRlIGZvciBGUkVFIGhlYWQg
b3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcwDgYDVR0PAQH/BAQDAgOoMEAGA1UdJQQ5
MDcGCCsGAQUFBwMEBggrBgEFBQcDAgYKKwYBBAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4
QgQBMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9y
ZzAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLmNhY2VydC5vcmcvcmV2b2tlLmNybDA0
BgNVHREELTArgRRhaGZlcnJvaW43QGdtYWlsLmNvbYETYWhlbW1lbGdAb2hpb2d0LmNvbTAN
BgkqhkiG9w0BAQ0FAAOCAgEAGvl7xb42JMRH5D/vCIDYvFY3dR2FPd5kmOqpKU/fvQ8ovmJa
p5N/FDrsCL+YdslxPY+AAn78PYmL5pFHTdRadT++07DPIMtQyy2qd+XRmz6zP8Il7vGcEDmO
WmMLYMq4xV9s/N7t7JJp6ftdIYUcoTVChUgilDaRWMLidtslCdRsBVfUjPb1bF5Ua31diKDP
e0M9/e2CU36rbcTtiNCXhptMigzuL3zJXUf2B9jyUV8pnqNEQH36fqJ7YTBLcpq3aYa2XbAH
Hgx9GehJBIqwspDmhPCFZ/QmqUXCkt+XfvinQ2NzKR6P3+OdYbwqzVX8BdMeojh7Ig8x/nIx
mQ+/ufstL1ZYp0bg13fyK/hPYSIBpayaC76vzWovkIm70DIDRIFLi20p/qTd7rfDYy831Hjm
+lDdCECF9bIXEWFk33kA97dgQIMbf5chEmlFg8S0e4iw7LMjvRqMX3eCD8GJ2+oqyZUwzZxy
S0Mx+rBld5rrN7LsXwZ671HsGqNeYbYeU25e7t7/Gcc6Bd/kPfA+adEuUGFcvUKH3trDYqNq
6mOkAd8WO/mQadlc3ztS++XDMhmIpfBre9MPAr6usqf+wc+R8Nk9KLK39kEgrqVfzc/fgf8L
MaD4rHnusdg4gca6Yi+kNrm99anw7SwaBrBvULYBp7ixNRUhaYiNW4YjTrYxggShMIIEnQIB
ATCBgDB5MRAwDgYDVQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5v
cmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEW
EnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5VMAkGBSsOAwIaBQCgggH1MBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDYwNTExMjg1N1owIwYJKoZIhvcNAQkE
MRYEFETsFAzX2tlt9Pz6URTRZ3N04KVUMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAAUeybENZE2cw8pqNu5AdNT5jGPRoarMEVkK7FpnPFwCnHwL
y+W70brTsiP5LhzqL5Vq4cLjoWGk/uyMm671v+grR7wn6ALn1ZangltsZ8gOLUmp1aHbtoyR
aUfqE+A2GV+0Tn6Erpitd2DKe7GP9SMjHJrjYx9lLr7q3qP5h0GT324q2j6LEK15d2HzYj38
b6SxlUcX5uz8hSq4dp/YXv+LDrnjUksrJyyj3RxafcUtipf9Ib3oPGYqz4ImM7baeMFe8CMM
Ym/HmNFrI42RwpWggfewSOOgqrgn3bpil4aZUpMZJpJ9CQypOdBdq5lIFHm2OdpJhGi+0bdj
R7gr8QYkGDGWmn21y/78KCdrJWJIKh+CkwqOuhUhjDKW1hHOfJIWS6Z8F6VYvGDS4ctmU1A0
QvFg8CQpP3JtDkM/MgsnvbwW4tqH7UJkHvleCo6CETgiDzzqS7N5I372WyGS0SscoQjmKeCX
u9UmRDf9sBem3/rKY5hBDmMEomFfiV6nKqqR8difXPGyKrMq/JZq8fPAIz9OvYOSPrloqK3x
kW+rEAVzK9Cg8I7VzzyYKT0y3lHVO5IxMVr8AaRusLwvr/1EzneLx8Ipv1ZeIGpu1vieIfUi
oehQyf590kkAbTW6UquT3QhN2izQaaXGNG015DscFpizuJy1NcZMw1GI2f4mAAAAAAAA
--------------ms010302080500080207080006--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
