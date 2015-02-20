Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id CC93F6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 12:40:19 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id k14so14560409wgh.3
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 09:40:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vs8si47978981wjc.119.2015.02.20.09.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 09:40:18 -0800 (PST)
Message-ID: <54E77162.3050203@redhat.com>
Date: Fri, 20 Feb 2015 18:39:46 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 04/24] rmap: add argument to charge compound page
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com> <54DD16BD.4000201@redhat.com> <20150216152056.GC3270@node.dhcp.inet.fi>
In-Reply-To: <20150216152056.GC3270@node.dhcp.inet.fi>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="sJXQCif7B1ap56hHr7elVW7GsoKRjB6NQ"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sJXQCif7B1ap56hHr7elVW7GsoKRjB6NQ
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/16/2015 04:20 PM, Kirill A. Shutemov wrote:
> On Thu, Feb 12, 2015 at 04:10:21PM -0500, Rik van Riel wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> On 02/12/2015 11:18 AM, Kirill A. Shutemov wrote:
>>
>>> +++ b/include/linux/rmap.h @@ -168,16 +168,24 @@ static inline void
>>> anon_vma_merge(struct vm_area_struct *vma,
>>>
>>> struct anon_vma *page_get_anon_vma(struct page *page);
>>>
>>> +/* flags for do_page_add_anon_rmap() */ +enum { +	RMAP_EXCLUSIVE =3D=

>>> 1, +	RMAP_COMPOUND =3D 2, +};
>>
>> Always a good idea to name things. However, "exclusive" is
>> not that clear to me. Given that the argument is supposed
>> to indicate whether we map a single or a compound page,
>> maybe the names in the enum could just be SINGLE and COMPOUND?
>>
>> Naming the enum should make it clear enough what it does:
>>
>>  enum rmap_page {
>>       SINGLE =3D 0,
>>       COMPOUND
>>  }
>=20
> Okay, this is probably confusing: do_page_add_anon_rmap() already had o=
ne
> of arguments called 'exclusive'. It indicates if the page is exclusivel=
y
> owned by the current process. And I needed also to indicate if we need =
to
> handle the page as a compound or not. I've reused the same argument and=

> converted it to set bit-flags: bit 0 is exclusive, bit 1 - compound.

AFAICT, this is not a common use of enum and probably the reason why Rik
was confused (I know I find it confusing). Bit-flags members are usually
define by macros.

Jerome
>=20
>>
>>> +++ b/kernel/events/uprobes.c @@ -183,7 +183,7 @@ static int
>>> __replace_page(struct vm_area_struct *vma, unsigned long addr, goto
>>> unlock;
>>>
>>> get_page(kpage); -	page_add_new_anon_rmap(kpage, vma, addr); +
>>> page_add_new_anon_rmap(kpage, vma, addr, false);=20
>>> mem_cgroup_commit_charge(kpage, memcg, false);=20
>>> lru_cache_add_active_or_unevictable(kpage, vma);
>>
>> Would it make sense to use the name in the argument to that function,
>> too?
>>
>> I often find it a lot easier to see what things do if they use symboli=
c
>> names, rather than by trying to remember what each boolean argument to=

>> a function does.
>=20
> I can convert these compound booleans to enums if you want. I'm persona=
lly
> not sure that if will bring much value.
>=20



--sJXQCif7B1ap56hHr7elVW7GsoKRjB6NQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU53FiAAoJEHTzHJCtsuoCTdwH/13iVIA/H12MMG6hDT0XrIJL
RCktxwTbrWMo4VvPRU3FAQ08GAzT8h60cqWHwoopItHr31x8q311ckWJcvpJ3ezh
gHLmxn+b0NzqmZA7wY1KGU7CtUv6ZXo2658MFaeDrQJtAfY6vE5dKXHreilwvzcD
GardOjQZm1C8kuiUS1bo6SSMDs8nhwOkNxms8tSFXLQnF8zvuv9WU9gxMtx1rwfb
6xhjf2XdMcwynxKEbGJU7PqYLeQAPRUiPJmKJ4vAgeCRmw3DwaaOXI/iUkW45JA1
gIdqps7KMUkEZws6KADphb3PXDUpJqgfel2BfvkXzeYTPYWTmgCp3be1y/fBhZE=
=wlbJ
-----END PGP SIGNATURE-----

--sJXQCif7B1ap56hHr7elVW7GsoKRjB6NQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
