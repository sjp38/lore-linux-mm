Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8BD06B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:25:41 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c20so5437041qkm.13
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:25:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e11-v6si12313900qtf.225.2018.04.25.07.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 07:25:41 -0700 (PDT)
Subject: Re: [Qemu-devel] [RFC v2] qemu: Add virtio pmem device
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180425112415.12327-4-pagupta@redhat.com>
From: Eric Blake <eblake@redhat.com>
Message-ID: <25f3e433-cfa6-4a62-ba7f-47aef1119dfc@redhat.com>
Date: Wed, 25 Apr 2018 09:25:37 -0500
MIME-Version: 1.0
In-Reply-To: <20180425112415.12327-4-pagupta@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="CFJqPHc1lVbGj70GneZIm5syNGVZjNCpA"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: kwolf@redhat.com, haozhong.zhang@intel.com, jack@suse.cz, xiaoguangrong.eric@gmail.com, riel@surriel.com, niteshnarayanlal@hotmail.com, david@redhat.com, ross.zwisler@intel.com, lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com, stefanha@redhat.com, imammedo@redhat.com, marcel@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com, nilal@redhat.com

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CFJqPHc1lVbGj70GneZIm5syNGVZjNCpA
Content-Type: multipart/mixed; boundary="1IGSjTW0uM1A8ilmt1jp7ZPWiEf26VDfr";
 protected-headers="v1"
From: Eric Blake <eblake@redhat.com>
To: Pankaj Gupta <pagupta@redhat.com>, linux-kernel@vger.kernel.org,
 kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org,
 linux-mm@kvack.org
Cc: kwolf@redhat.com, haozhong.zhang@intel.com, jack@suse.cz,
 xiaoguangrong.eric@gmail.com, riel@surriel.com,
 niteshnarayanlal@hotmail.com, david@redhat.com, ross.zwisler@intel.com,
 lcapitulino@redhat.com, hch@infradead.org, mst@redhat.com,
 stefanha@redhat.com, imammedo@redhat.com, marcel@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com, nilal@redhat.com
Message-ID: <25f3e433-cfa6-4a62-ba7f-47aef1119dfc@redhat.com>
Subject: Re: [Qemu-devel] [RFC v2] qemu: Add virtio pmem device
References: <20180425112415.12327-1-pagupta@redhat.com>
 <20180425112415.12327-4-pagupta@redhat.com>
In-Reply-To: <20180425112415.12327-4-pagupta@redhat.com>

--1IGSjTW0uM1A8ilmt1jp7ZPWiEf26VDfr
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 04/25/2018 06:24 AM, Pankaj Gupta wrote:
> This patch adds virtio-pmem Qemu device.
>=20
> This device presents memory address range=20
> information to guest which is backed by file=20
> backend type. It acts like persistent memory=20
> device for KVM guest. Guest can perform read=20
> and persistent write operations on this memory=20
> range with the help of DAX capable filesystem.
>=20
> Persistent guest writes are assured with the=20
> help of virtio based flushing interface. When=20
> guest userspace space performs fsync on file=20
> fd on pmem device, a flush command is send to=20
> Qemu over VIRTIO and host side flush/sync is=20
> done on backing image file.
>=20
> This PV device code is dependent and tested=20
> with 'David Hildenbrand's ' patchset[1] to=20
> map non-PCDIMM devices to guest address space.

This sentence doesn't belong in git history.  It is better to put
information like this...

> There is still upstream discussion on using=20
> among PCI bar vs memory device, will update=20
> as per concensus.

s/concensus/consensus/

>=20
> [1] https://marc.info/?l=3Dqemu-devel&m=3D152450249319168&w=3D2
>=20
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> ---

=2E..here, where it is part of the email, but not picked up by 'git am'.


> +++ b/qapi/misc.json
> @@ -2871,6 +2871,29 @@
>            }
>  }
> =20
> +##
> +# @VirtioPMemDeviceInfo:
> +#
> +# VirtioPMem state information
> +#
> +# @id: device's ID
> +#
> +# @start: physical address, where device is mapped
> +#
> +# @size: size of memory that the device provides
> +#
> +# @memdev: memory backend linked with device
> +#
> +# Since: 2.13
> +##
> +{ 'struct': 'VirtioPMemDeviceInfo',
> +    'data': { '*id': 'str',
> +	      'start': 'size',
> +	      'size': 'size',

TAB damage.

> +              'memdev': 'str'
> +	    }
> +}
> +
>  ##
>  # @MemoryDeviceInfo:
>  #
> @@ -2880,7 +2903,8 @@
>  ##
>  { 'union': 'MemoryDeviceInfo',
>    'data': { 'dimm': 'PCDIMMDeviceInfo',
> -            'nvdimm': 'PCDIMMDeviceInfo'
> +            'nvdimm': 'PCDIMMDeviceInfo',
> +	    'virtio-pmem': 'VirtioPMemDeviceInfo'
>            }
>  }
> =20
>=20

--=20
Eric Blake, Principal Software Engineer
Red Hat, Inc.           +1-919-301-3266
Virtualization:  qemu.org | libvirt.org


--1IGSjTW0uM1A8ilmt1jp7ZPWiEf26VDfr--

--CFJqPHc1lVbGj70GneZIm5syNGVZjNCpA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: Public key at http://people.redhat.com/eblake/eblake.gpg
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEzBAEBCAAdFiEEccLMIrHEYCkn0vOqp6FrSiUnQ2oFAlrgj+EACgkQp6FrSiUn
Q2oftQgAkgISPCCNGA8QYSXkQfHKQ2qPa3CR6cJ1vSVXjJWEsPypyfrQ4P/caxJC
OaTfjufz0Tgn/kn1MOzeDYgQGnOjYZJC+1YYcMhR8arrUb6Whv4ejHpnXGNC1lxJ
hLcRxPhD7fg7CW55xgi/pXF1OLUxMMQdtyd57SCW5rCt5NPi8TZRsDOiM34KEbDW
EewLjBrjnueBaLVywp5I0KFODWua4/qSmkzB3E/EnHw66uHKrWH0PAHnH2s3OnwL
0o4eBB2YnSrf2eKCuLY5XvJwD9HyRQm9h6sKnuP7+PqzaLlycHphA1jfOL+hNK2w
txr4zrD38INfFRWQy0QHUt84HMGbPg==
=ylBq
-----END PGP SIGNATURE-----

--CFJqPHc1lVbGj70GneZIm5syNGVZjNCpA--
