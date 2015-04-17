Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id C85A06B0073
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:23:41 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so11275301igb.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:23:41 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id ve2si1596538igb.43.2015.04.17.06.23.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 06:23:41 -0700 (PDT)
Received: by igbhj9 with SMTP id hj9so11693756igb.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:23:41 -0700 (PDT)
Message-ID: <55310957.3070101@gmail.com>
Date: Fri, 17 Apr 2015 09:23:35 -0400
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com>
In-Reply-To: <553104E5.2040704@samsung.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms060600010201050509090607"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>, Jan Kara <jack@suse.cz>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms060600010201050509090607
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-04-17 09:04, Beata Michalska wrote:
> On 04/17/2015 01:31 PM, Jan Kara wrote:
>> On Wed 15-04-15 09:15:44, Beata Michalska wrote:
>> ...
>>> +static const match_table_t fs_etypes =3D {
>>> +	{ FS_EVENT_INFO,    "info"  },
>>> +	{ FS_EVENT_WARN,    "warn"  },
>>> +	{ FS_EVENT_THRESH,  "thr"   },
>>> +	{ FS_EVENT_ERR,     "err"   },
>>> +	{ 0, NULL },
>>> +};
>>    Why are there these generic message types? Threshold messages make =
good
>> sense to me. But not so much the rest. If they don't have a clear mean=
ing,
>> it will be a mess. So I also agree with a message like - "filesystem h=
as
>> trouble, you should probably unmount and run fsck" - that's fine. But
>> generic "info" or "warning" doesn't really carry any meaning on its ow=
n and
>> thus seems pretty useless to me. To explain a bit more, AFAIU this
>> shouldn't be a generic logging interface where something like severity=

>> makes sense but rather a relatively specific interface notifying about=

>> events in filesystem userspace should know about so I expect relativel=
y low
>> number of types of events, not tens or even hundreds...
>>
>> 								Honza
>
> Getting rid of those would simplify the configuration part, indeed.
> So we would be left with 'generic' and threshold events.
> I guess I've overdone this part.

For some filesystems, it may make sense to differentiate between a=20
generic warning and an error.  For BTRFS and ZFS for example, if there=20
is a csum error on a block, this will get automatically corrected in=20
many configurations, and won't require anything like fsck to be run, but =

monitoring applications will still probably want to be notified.


--------------ms060600010201050509090607
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
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDQxNzEzMjMzNVowIwYJKoZIhvcNAQkE
MRYEFASu1U6YQ0rgczHQYTDFjRMIT0EkMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAGNWa944vc2+KzwXyrYAFj6jbQ5gJTq3db/8AhL0DPSR2GKT
KduymTC43QPHEolixSt7a6zUVlVcjvXYb91U6zDEoN7k4CoEqQBKZfv6B/sNtRXiZax9ZHfj
yVez4SbZTRqPMX7M5yB9/Ie32kNBBcL5mcg+zCAzuN68MC5eAqAh9A3vRsss8WvGND1B63I9
fBZ+r+rAKkC2kylrn1IvMjuWcf7GVIQ4p0WEeyPueLUUnrScR6rjADHJwlZcLXOnw5odykSA
FUOWKM9GI09bxC1kpq7rNzHzRoSlzo7yp8UT7whbi+KXWkFB365gA8IFIrPPDUKs6vgilB0D
CIBbRlFUGkfGtPBuab/JPUc2hR8MY1t6B5A3dbDfHtopusAi3fCl49Yd8CsVPgHqae+TuBuK
Oubqsn2XYu/c4TB3KWR/HFGbwEizk3pOy6aycYaJwhX3W9YfLdzo8YWgK768drhkEmaEg3Hg
q67IO+gmYVS6G2aWZQwK9vKZSCnVFVw4cEoGsab0X2gRbJw1RFes9a77IwhXwfriEh27yw4R
m4ZM+CqQEtJjicT13se4hX9JyKgumH65lVkUo3VEI7p2ilCV6V1pGDCJ9bVBkEJm5+w7lTM3
PFB9ewCegDebwodmBQOFjeNgtumykAFjz4gOklld4L2jugwlNCdtiwTBWWSKAAAAAAAA
--------------ms060600010201050509090607--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
