Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1123B82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 21:19:51 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so181811387wic.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 18:19:50 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id kw5si53389968wjb.201.2015.10.27.18.19.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 18:19:49 -0700 (PDT)
Message-ID: <1445995167.3405.165.camel@infradead.org>
Subject: Re: [PATCH v11 15/15] HMM: add documentation explaining HMM
 internals and how to use it.
From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 28 Oct 2015 10:19:27 +0900
In-Reply-To: <562856BD.3020806@infradead.org>
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
	 <1445461210-2605-16-git-send-email-jglisse@redhat.com>
	 <562856BD.3020806@infradead.org>
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-VMYLR2h1BG93s0eaKyG8"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>


--=-VMYLR2h1BG93s0eaKyG8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-10-21 at 20:23 -0700, Randy Dunlap wrote:
> On 10/21/15 14:00, J=C3=83=C2=A9r=C3=83=C2=B4me Glisse wrote:
...
> > Signed-off-by: J=C3=83=C2=A9r=C3=83=C2=B4me Glisse <jglisse@redhat.com>

Not sure how Randy's email screwed that one up; it was a perfectly fine
instance of your name.

> > +++ b/Documentation/vm/hmm.txt
> > @@ -0,0 +1,219 @@
> > +Heterogeneous Memory Management (HMM)
> > +-------------------------------------
> > +
> > +The raison d'=C3=AF=C2=BF=C2=BDtre of HMM is to provide a common API..=
.

That one, on the other hand, was yours. Your original commit in your
git tree has that '=C3=AA' character in some legacy 8-bit character set
instead of UTF-8. Did it fall through a time-warp from the 20th
century? :)

--=20
dwmw2



--=-VMYLR2h1BG93s0eaKyG8
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUxMDI4MDExOTI5WjAjBgkqhkiG9w0BCQQxFgQU2IdPmuO1Dyuxb0aI/hHUBKqkUrsw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQBGoSV9kCTzZTw9k4u/kLjqi79i00ZF29V+67P1TR1aYj0cRu3kxTMcdBVr
Brek0Jkn8aBizdsN+ov9cX/mKRe+SZIMrkFaMjTgWt5UsazSsxJFGxUcO/B7drcDaN3MHgggB3kR
Jz32Yfw63zWsA5jDRiStgSW6Gx9kQjAIHriKgUiO0WNo/R33d1jNsQeB7k+vhDy8KIqQcozx3uzq
ey4pIOBoIk72kVcznwS0wnkVyzvK71s1todHmdik0xcEfuzWy/T/ypbRdsyaN+EzyEu3Kd8zmpAA
hOedCucqNP24BN7g4DcPtEIlCtMsMtKkFRdETiCRSJHDM/ZIAMUCmnQ9AAAAAAAA


--=-VMYLR2h1BG93s0eaKyG8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
