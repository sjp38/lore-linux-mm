Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 625596B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 17:34:38 -0400 (EDT)
Received: by paccq16 with SMTP id cq16so97341991pac.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 14:34:38 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qp7si11923676pbc.93.2015.08.18.14.34.29
        for <linux-mm@kvack.org>;
        Tue, 18 Aug 2015 14:34:29 -0700 (PDT)
Message-ID: <1439933668.3006.20.camel@intel.com>
Subject: Re: [Intel-wired-lan] [Patch V3 6/9] i40evf: Use numa_mem_id() to
 better support memoryless node
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Aug 2015 14:34:28 -0700
In-Reply-To: <4197C471DCF8714FBA1FE32565271C148FFF786A@ORSMSX103.amr.corp.intel.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
	 <1439781546-7217-7-git-send-email-jiang.liu@linux.intel.com>
	 <4197C471DCF8714FBA1FE32565271C148FFF786A@ORSMSX103.amr.corp.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RI84y0u0A0e3tUw0RGcA"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Patil, Kiran" <kiran.patil@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>


--=-RI84y0u0A0e3tUw0RGcA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-08-17 at 12:03 -0700, Patil, Kiran wrote:
> ACK.
>=20

Just an FYI, top posting is frowned upon in the Linux public mailing
lists.  Also, if you really want your ACK to be added to the patch, you
need to reply with:

Acked-by: Kiran Patil <kiran.patil@intel.com>

> -----Original Message-----
> From: Intel-wired-lan
> [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Jiang
> Liu
> Sent: Sunday, August 16, 2015 8:19 PM
> To: Andrew Morton; Mel Gorman; David Rientjes; Mike Galbraith; Peter
> Zijlstra; Wysocki, Rafael J; Tang Chen; Tejun Heo; Kirsher, Jeffrey T;
> Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A
> Cc: Luck, Tony; netdev@vger.kernel.org; x86@kernel.org;
> linux-hotplug@vger.kernel.org; linux-kernel@vger.kernel.org;
> linux-mm@kvack.org; intel-wired-lan@lists.osuosl.org; Jiang Liu
> Subject: [Intel-wired-lan] [Patch V3 6/9] i40evf: Use numa_mem_id() to
> better support memoryless node
>=20
> Function i40e_clean_rx_irq() tries to reuse memory pages allocated
> from the nearest node. To better support memoryless node, use
> numa_mem_id() instead of numa_node_id() to get the nearest node with
> memory.
>=20
> This change should only affect performance.
>=20
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)



--=-RI84y0u0A0e3tUw0RGcA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJV06TkAAoJEOVv75VaS+3OCxQP/2zKDLypd+yDET2EuNwV60s6
w7eD7ZcbjLrE7IQyhEBrj9QKotbop8Dd/9+UwKoZURwjeuLxkIIIy8GacvacC4+x
YVNai8LGSU55T1JfV+zYGXq0+iSBgJNputBVjjiZ7GxA9+mCTCMRaKgC6+eBdKRS
SqFfQRnxD6wQHDWmoJz1C+OtJYZYmHvcw6wwjr2q8L0v+7uUw7O+LfQNhjl5ypZe
tqP0a1XALdVlOz7RuoydnwYoY5Fgu/rePsW4z1DNcWG6CoyP9Xk1Fs7uwtLXRqCS
17vltTuhf30uPaL7AUMsJVxVhwFzEEGwq/tocsopP8L5zIDktLS8KW1BeNrJfxkD
N6xkUI0mi6E7j3oxDafAaCwaR7twBn3oClfEwwuWqQf+rheYFAYPTZUV4SoiQylq
CgwsfpcHHrQH/N8sj/Nia0gCbky6l2yavHSKVSWvWxHOimGhX5ycT7AwWhAFTZuc
4hjqUD7L7bE1/vsz5f1lg4mNgzVr1SoPSo/xwbBYSJxa4k2540o5ddRChry93GSx
w4090tWm8y4lTOLpMB6lZ7hQ/K2j5AWhDVo5FiaiAp1bmC2cBuApEnpuZ3JyTUb7
O1zrT72Vzma1EiuQ6PU8q8xn46DBJ4SMfqL/r/67yHu0OfUnqlRq+U8obsMdO+BT
v5zISHIwCeASYadtWlip
=KtHN
-----END PGP SIGNATURE-----

--=-RI84y0u0A0e3tUw0RGcA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
