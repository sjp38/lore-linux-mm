Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D4BA6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 09:40:58 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id at20so7674757iec.33
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 06:40:58 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id t19si8929513igr.12.2014.09.02.06.40.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 06:40:57 -0700 (PDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so14190743igb.9
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 06:40:57 -0700 (PDT)
Message-ID: <5405C8DF.7080602@gmail.com>
Date: Tue, 02 Sep 2014 09:40:47 -0400
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: ext4 vs btrfs performance on SSD array
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>	<20140902000822.GA20473@dastard>	<20140902012222.GA21405@infradead.org> <CAA8KC9Lgjf_FBXnKAaJtp6=NCWsoCFOobgi5b84BXfAcbgynJQ@mail.gmail.com>
In-Reply-To: <CAA8KC9Lgjf_FBXnKAaJtp6=NCWsoCFOobgi5b84BXfAcbgynJQ@mail.gmail.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms070006090103080102010005"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zack Coffey <clickwir@gmail.com>
Cc: linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org

This is a cryptographically signed message in MIME format.

--------------ms070006090103080102010005
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I wholeheartedly agree.  Of course, getting something other than CFQ as
the default I/O scheduler is going to be a difficult task.  Enough
people upstream are convinced that we all NEED I/O priorities, when most
of what I see people doing with them is bandwidth provisioning, which
can be done much more accurately (and flexibly) using cgroups.

Ironically, there have been a lot of in-kernel defaults that I have run
into issues with recently, most of which originated in the DOS era,
where a few MB of RAM was high-end.

On 2014-09-02 08:55, Zack Coffey wrote:
> While I'm sure some of those settings were selected with good reason,
> maybe there can be a few options (2 or 3) that have some basic
> intelligence at creation to pick a more sane option.
>=20
> Some checks to see if an option or two might be better suited for the
> fs. Like the RAID5 stripe size. Leave the default as is, but maybe a
> quick speed test to automatically choose from a handful of the most
> common values. If they fail or nothing better is found, then apply the
> default value just like it would now.
>=20
>=20
> On Mon, Sep 1, 2014 at 9:22 PM, Christoph Hellwig <hch@infradead.org> w=
rote:
>> On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:
>>> Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4
>>> and XFS are doing is doing 128k IOs because that's the default block
>>> device readahead size.  'blockdev --setra 1024 /dev/sdd' before
>>> mounting the filesystem will probably fix it.
>>
>> Btw, it's really getting time to make Linux storage fs work out the
>> box.  There's way to many things that are stupid by default and we
>> require everyone to fix up manually:
>>
>>  - the ridiculously low max_sectors default
>>  - the very small max readahead size
>>  - replacing cfq with deadline (or noop)
>>  - the too small RAID5 stripe cache size
>>
>> and probably a few I forgot about.  It's time to make things perform
>> well out of the box..
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-btrfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20



--------------ms070006090103080102010005
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFuDCC
BbQwggOcoAMCAQICAw9gVDANBgkqhkiG9w0BAQ0FADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0xNDA4
MDgxMTMwNDRaFw0xNTAyMDQxMTMwNDRaMGMxGDAWBgNVBAMTD0NBY2VydCBXb1QgVXNlcjEj
MCEGCSqGSIb3DQEJARYUYWhmZXJyb2luN0BnbWFpbC5jb20xIjAgBgkqhkiG9w0BCQEWE2Fo
ZW1tZWxnQG9oaW9ndC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDdmm8R
BM5D6fGiB6rpogPZbLYu6CkU6834rcJepfmxKnLarYUYM593/VGygfaaHAyuc8qLaRA3u1M0
Qp29flqmhv1VDTBZ+zFu6JgHjTDniBii1KOZRo0qV3jC5NvaS8KUM67+eQBjm29LhBWVi3+e
a8jLxmogFXV0NGej+GHIr5zA9qKz2WJOEoGh0EfqZ2MQTmozcGI43/oqIYhRj8fRMkWXLUAF
WsLzPQMpK19hD8fqwlxQWhBV8gsGRG54K5pyaQsjne7m89SF5M8JkNJPH39tHEvfv2Vhf7EM
Y4WGyhLAULSlym1AI1uUHR1FfJaj3AChaEJZli/AdajYsqc7AgMBAAGjggFZMIIBVTAMBgNV
HRMBAf8EAjAAMFYGCWCGSAGG+EIBDQRJFkdUbyBnZXQgeW91ciBvd24gY2VydGlmaWNhdGUg
Zm9yIEZSRUUgaGVhZCBvdmVyIHRvIGh0dHA6Ly93d3cuQ0FjZXJ0Lm9yZzAOBgNVHQ8BAf8E
BAMCA6gwQAYDVR0lBDkwNwYIKwYBBQUHAwQGCCsGAQUFBwMCBgorBgEEAYI3CgMEBgorBgEE
AYI3CgMDBglghkgBhvhCBAEwMgYIKwYBBQUHAQEEJjAkMCIGCCsGAQUFBzABhhZodHRwOi8v
b2NzcC5jYWNlcnQub3JnMDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly9jcmwuY2FjZXJ0Lm9y
Zy9yZXZva2UuY3JsMDQGA1UdEQQtMCuBFGFoZmVycm9pbjdAZ21haWwuY29tgRNhaGVtbWVs
Z0BvaGlvZ3QuY29tMA0GCSqGSIb3DQEBDQUAA4ICAQCr4klxcZU/PDRBpUtlb+d6JXl2dfto
OUP/6g19dpx6Ekt2pV1eujpIj5whh5KlCSPUgtHZI7BcksLSczQbxNDvRu6LNKqGJGvcp99k
cWL1Z6BsgtvxWKkOmy1vB+2aPfDiQQiMCCLAqXwHiNDZhSkwmGsJ7KHMWgF/dRVDnsl6aOQZ
jAcBMpUZxzA/bv4nY2PylVdqJWp9N7x86TF9sda1zRZiyUwy83eFTDNzefYPtc4MLppcaD4g
Wt8U6T2ffQfCWVzDirhg4WmDH3MybDItjkSB2/+pgGOS4lgtEBMHzAGQqQ+5PojTHRyqu9Jc
O59oIGrTaOtKV9nDeDtzNaQZgygJItJi9GoAl68AmIHxpS1rZUNV6X8ydFrEweFdRTVWhUEL
70Cnx84YBojXv01LYBSZaq18K8cERPLaIrUD2go+2ffjdE9ejvYDhNBllY+ufvRizIjQA1uC
OdktVAN6auQob94kOOsWpoMSrzHHvOvVW/kbokmKzaLtcs9+nJoL+vPi2AyzbaoQASVZYOGW
pE3daA0F5FJfcPZKCwd5wdnmT3dU1IRUxa5vMmgjP20lkfP8tCPtvZv2mmI2Nw5SaXNY4gVu
WQrvkV2in+TnGqgEIwUrLVbx9G6PSYZZs07czhO+Q1iVuKdAwjL/AYK0Us9v50acIzbl5CWw
ZGj3wjGCA6EwggOdAgEBMIGAMHkxEDAOBgNVBAoTB1Jvb3QgQ0ExHjAcBgNVBAsTFWh0dHA6
Ly93d3cuY2FjZXJ0Lm9yZzEiMCAGA1UEAxMZQ0EgQ2VydCBTaWduaW5nIEF1dGhvcml0eTEh
MB8GCSqGSIb3DQEJARYSc3VwcG9ydEBjYWNlcnQub3JnAgMPYFQwCQYFKw4DAhoFAKCCAfUw
GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTQwOTAyMTM0MDQ3
WjAjBgkqhkiG9w0BCQQxFgQUQP+QsX3mfNJxPCRUZOnzzS5mkrYwbAYJKoZIhvcNAQkPMV8w
XTALBglghkgBZQMEASowCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIA
gDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIBKDCBkQYJKwYBBAGCNxAE
MYGDMIGAMHkxEDAOBgNVBAoTB1Jvb3QgQ0ExHjAcBgNVBAsTFWh0dHA6Ly93d3cuY2FjZXJ0
Lm9yZzEiMCAGA1UEAxMZQ0EgQ2VydCBTaWduaW5nIEF1dGhvcml0eTEhMB8GCSqGSIb3DQEJ
ARYSc3VwcG9ydEBjYWNlcnQub3JnAgMPYFQwgZMGCyqGSIb3DQEJEAILMYGDoIGAMHkxEDAO
BgNVBAoTB1Jvb3QgQ0ExHjAcBgNVBAsTFWh0dHA6Ly93d3cuY2FjZXJ0Lm9yZzEiMCAGA1UE
AxMZQ0EgQ2VydCBTaWduaW5nIEF1dGhvcml0eTEhMB8GCSqGSIb3DQEJARYSc3VwcG9ydEBj
YWNlcnQub3JnAgMPYFQwDQYJKoZIhvcNAQEBBQAEggEAUikQqc0S09u1yn97hHpSkct+lZOX
eI+u+pG/P+ESz6mwhzQvXMTjst5N/bp5gJgFyrEGl+j3D6Zztfj+l7V0MCiIhNarW/gm8WsA
QLO98K2OnyP31ba31OSOViJsiwWMEW2MZjvYfIuL448VBTez6xcQH3RK2Ddm8DRmNBXgZ+Dp
fjNlMk6FDj4WSfVSOfmb/z8p+LzkBVK8B3l/5f8Dg9j1PoXUuJDOZy+QGs7EV9Luemr4MkjP
oI3wdmlArAq8pXNO4fVOuyVOunY/BjKShYHatMBKgLrM2ppuBEVr8EOY821ueAEk9fNDrIMk
ta7wEWVIXfO1heJRvMAF5tHWCgAAAAAAAA==
--------------ms070006090103080102010005--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
