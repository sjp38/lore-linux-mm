Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 56B0E6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:29:13 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so85949375ied.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:29:13 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id to18si10633150icb.91.2015.04.17.09.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 09:29:12 -0700 (PDT)
Received: by iecrt8 with SMTP id rt8so63749101iec.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:29:12 -0700 (PDT)
Message-ID: <553134D3.9040001@gmail.com>
Date: Fri, 17 Apr 2015 12:29:07 -0400
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com> <1429082147-4151-2-git-send-email-b.michalska@samsung.com> <20150417113110.GD3116@quack.suse.cz> <553104E5.2040704@samsung.com> <55310957.3070101@gmail.com> <55311DE2.9000901@redhat.com> <20150417154351.GA26736@quack.suse.cz> <55312FEA.3030905@redhat.com> <20150417162247.GB27500@quack.suse.cz>
In-Reply-To: <20150417162247.GB27500@quack.suse.cz>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms010802090100020900070806"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, John Spray <john.spray@redhat.com>
Cc: Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms010802090100020900070806
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-04-17 12:22, Jan Kara wrote:
> On Fri 17-04-15 17:08:10, John Spray wrote:
>>
>> On 17/04/2015 16:43, Jan Kara wrote:
>>> On Fri 17-04-15 15:51:14, John Spray wrote:
>>>> On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
>>>>
>>>>> For some filesystems, it may make sense to differentiate between a
>>>>> generic warning and an error.  For BTRFS and ZFS for example, if
>>>>> there is a csum error on a block, this will get automatically
>>>>> corrected in many configurations, and won't require anything like
>>>>> fsck to be run, but monitoring applications will still probably
>>>>> want to be notified.
>>>> Another key differentiation IMHO is between transient errors (like
>>>> server is unavailable in a distributed filesystem) that will block
>>>> the filesystem but might clear on their own, vs. permanent errors
>>>> like unreadable drives that definitely will not clear until the
>>>> administrator takes some action.  It's usually a reasonable
>>>> approximation to call transient issues warnings, and permanent
>>>> issues errors.
>>>    So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but wh=
at use
>>> would this have? I wouldn't like the interface to be dumping ground f=
or
>>> random crap - we have dmesg for that :).
>> In that case I'm confused -- why would ENOSPC be an appropriate use
>> of this interface if the mount being entirely blocked would be
>> inappropriate?  Isn't being unable to service any I/O a more
>> fundamental and severe thing than being up and healthy but full?
>>
>> Were you intending the interface to be exclusively for data
>> integrity issues like checksum failures, rather than more general
>> events about a mount that userspace would probably like to know
>> about?
>    Well, I'm not saying we cannot have those events for fs availability=
 /
> inavailability. I'm just saying I'd like to see some use for that first=
=2E
> I don't want events to be added just because it's possible...
>
> For ENOSPC we have thin provisioned storage and the userspace deamon
> shuffling real storage underneath. So there I know the usecase.
>
> 								Honza
>
The use-case that immediately comes to mind for me would be diskless=20
nodes with root-on-nfs needing to know if they can actually access the=20
root filesystem.


--------------ms010802090100020900070806
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
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDQxNzE2MjkwN1owIwYJKoZIhvcNAQkE
MRYEFIo3/dcmDxtWl2mLSdzIAd+UzU5kMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAEIZYTYhe5FfYKpm3u+Qwoj834YZUEIfefZWQTCiiTAseOoA
ebiT9YlLU7MjmNk5rgm4rGEt9fs8G06gVFlNhxdalTb6JFBf0pBti0bVeCPb6T81AfN4JXu5
I2GPAp/Gjg1fBEit+C5Wei3U+PqhfSTuSLN1KE6ZDtNIwGzU1BknzfOHrOPqpBLljo/QUhPK
zeSD1RMD3+649z0/dM6TD/7+5W55IssCDZg5kNLbrLNUkbePlrXD96CJ53HU+unE+RZG0l79
NvLL3hPfrNJcPQwHX5gZb8lb7Gi7uAnhl+25MURCuDk1QX5c0bohLl+XmaOntTZe7DBM0YM5
7wrvT5AraOK5kJ0Y0ane59ziBgNHlMMwr1LFGPaeWwhD8FQ9XP0YfwHgSx90DIUO3mnXvGWf
Xp334cDvy3kO/D9j8eSII0cXzgCD2C8kuoeAS9au0T42GBT9f0JDw7iYsG/owAvueIpzwJc+
5P0ks26yGDhBtsbWE1o/38T+Hm6gYAPrgACQcjhpNTJHUu6f+Qd6zCzsxJBRiQQ6YcWvSDUb
fyRRJDozXjM+lFWdgqISk490e2RNP3hFJeNnJrKhx+IKvCRtuloPA0CXORoE+kSABDdf0vtW
kg7+ug4tURW2T+mDODl++xTAH5UdeYhuKVCYqnAlE36mZsZugc2DZBYK78jYAAAAAAAA
--------------ms010802090100020900070806--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
