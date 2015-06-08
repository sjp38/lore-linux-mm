Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id A8DE56B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 14:59:02 -0400 (EDT)
Received: by yhpn97 with SMTP id n97so44034938yhp.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 11:59:02 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id y8si1237444ywy.31.2015.06.08.11.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 11:59:02 -0700 (PDT)
Received: by ykfr66 with SMTP id r66so56418351ykf.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 11:59:01 -0700 (PDT)
Message-ID: <5575E5E6.20908@gmail.com>
Date: Mon, 08 Jun 2015 14:58:46 -0400
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: split out forced OOM killer
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com> <557187F9.8020301@gmail.com> <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms080701090806070800040104"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms080701090806070800040104
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-06-08 13:59, David Rientjes wrote:
> On Fri, 5 Jun 2015, Austin S Hemmelgarn wrote:
>
>>> I'm not sure what the benefit of this is, and it's adding more code.
>>> Having multiple pathways and requirements, such as constrained_alloc(=
), to
>>> oom kill a process isn't any clearer, in my opinion.  It also isn't
>>> intended to be optimized since the oom killer called from the page
>>> allocator and from sysrq aren't fastpaths.  To me, this seems like on=
ly a
>>> source code level change and doesn't make anything more clear but rat=
her
>>> adds more code and obfuscates the entry path.
>>
>> At the very least, it does make the semantics of sysrq-f much nicer fo=
r admins
>> (especially the bit where it ignores the panic_on_oom setting, if the =
admin
>> wants the system to panic, he'll use sysrq-c).  There have been times =
I've had
>> to hit sysrq-f multiple times to get to actually kill anything, and th=
is looks
>> to me like it would eliminate that rather annoying issue as well.
>>
>
> Are you saying there's a functional change with this patch/
>
I believe so (haven't actually read the patch itself, just the=20
changelog), although it is only a change for certain configurations to a =

very specific and (I hope infrequently) used piece of functionality.=20
Like I said above, if I wanted to crash my system, I'd be using sysrq-c; =

and if I'm using sysrq-f, I want _some_ task to die _now_.


--------------ms080701090806070800040104
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
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDYwODE4NTg0NlowIwYJKoZIhvcNAQkE
MRYEFNlLXY4G4mLdHw8CIT6u7Dj1iEkpMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAB+mIOMzbUiFjcpWdl5SNKhF3+JpPaTKhCzq0yYy97oyc03G
GyvcQtXT16XBfxYRoSZ1od6q2AA4jyihzHQvWizJI9byKfTY8JzksOerAp/3gVCO8cQpA46N
/K0IIKVmj8QK246PT4aRRfUjipeCWQw3wEkUVzwy7LRm6abjCmQLibvDe5ZrhN+CXehusBj2
rqdVuC6ebGL0H0IdR5B35T1dRysjQAAWxajy8CrdZBn/ZaylY3UU4C8jmBTUyMwQZpzn+loK
equ4zGei6EYmj3kw13pgHaSKxgLKMacDELtNe/IVPnRb/ieciVsPO0dC90Dc9x23jYDK26ec
nBZmYEik72/JhLRGMJ8sdSEL5COdMDJ+2sndJpVgTPauKgwDFOqiTv5kKsnugm5jn3+2xCtE
TQcKCggoZDXX3cnaoNNeF69gMsZQeAaapdkewS+dEA+Zy5QB+w53NY2/wuMjU1z0yoQaxEGW
pebJW6wowetFBNxtAlcOep/E1WMfE/VT8/6/wR6noxuX9/6t7rKBfpcvvF5w4BiVhYNCiBpA
1UjkFkIOtdGIBBsVSVHWoJE9Juz+GotR8e2UX0ZZwKvrCMUXBsWNKCegsMnis7KMvzgZTSGq
R7MvGgJF5wA4vJyxOEzKGCKEagwHH2tRrA+R53BeXNSNAtMRGo/ZcOj6BlQ2AAAAAAAA
--------------ms080701090806070800040104--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
