Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 506E7C49ED9
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1282A20828
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 16:51:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1282A20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A535F6B0005; Mon,  9 Sep 2019 12:51:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A03836B0006; Mon,  9 Sep 2019 12:51:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F2F26B0007; Mon,  9 Sep 2019 12:51:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id 71B456B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 12:51:40 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 16CD5443F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:51:40 +0000 (UTC)
X-FDA: 75915973560.06.vest27_82dec5eb7f007
X-HE-Tag: vest27_82dec5eb7f007
X-Filterd-Recvd-Size: 9329
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:51:38 +0000 (UTC)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x89Go0ZN000785
	for <linux-mm@kvack.org>; Mon, 9 Sep 2019 12:51:38 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2uwsfeava3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Sep 2019 12:51:37 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 9 Sep 2019 17:51:35 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 9 Sep 2019 17:51:24 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x89GoxbI41157048
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 9 Sep 2019 16:50:59 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 85A0311C050;
	Mon,  9 Sep 2019 16:51:23 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 387CA11C04C;
	Mon,  9 Sep 2019 16:51:22 +0000 (GMT)
Received: from thinkpad (unknown [9.152.212.222])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon,  9 Sep 2019 16:51:22 +0000 (GMT)
Date: Mon, 9 Sep 2019 18:51:21 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil
 Babka <vbabka@suse.cz>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Mike Rapoport
 <rppt@linux.vnet.ibm.com>,
        Jason Gunthorpe <jgg@ziepe.ca>,
        Dan Williams
 <dan.j.williams@intel.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Michal
 Hocko <mhocko@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
        Mark Brown
 <broonie@kernel.org>, Steven Price <Steven.Price@arm.com>,
        Ard Biesheuvel
 <ard.biesheuvel@linaro.org>,
        Masahiro Yamada
 <yamada.masahiro@socionext.com>,
        Kees Cook <keescook@chromium.org>,
        Tetsuo
 Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Matthew Wilcox
 <willy@infradead.org>,
        Sri Krishna chowdary <schowdary@nvidia.com>,
        Dave
 Hansen <dave.hansen@intel.com>,
        Russell King - ARM Linux
 <linux@armlinux.org.uk>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Paul
 Mackerras <paulus@samba.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "David S. Miller"
 <davem@davemloft.net>,
        Vineet Gupta <vgupta@synopsys.com>, James Hogan
 <jhogan@kernel.org>,
        Paul Burton <paul.burton@mips.com>,
        Ralf Baechle
 <ralf@linux-mips.org>,
        linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/1] mm/pgtable/debug: Add test validating architecture
 page table helpers
In-Reply-To: <3d5de35f-8192-1c75-50a9-03e66e3b8e5c@arm.com>
References: <1567497706-8649-1-git-send-email-anshuman.khandual@arm.com>
	<1567497706-8649-2-git-send-email-anshuman.khandual@arm.com>
	<20190904221618.1b624a98@thinkpad>
	<20e3044d-2af5-b27b-7653-cec53bdec941@arm.com>
	<20190905190629.523bdb87@thinkpad>
	<3c609e33-afbb-ffaf-481a-6d225a06d1d0@arm.com>
	<20190906210346.5ecbff01@thinkpad>
	<3d5de35f-8192-1c75-50a9-03e66e3b8e5c@arm.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-TM-AS-GCONF: 00
x-cbid: 19090916-0020-0000-0000-00000369E0CB
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19090916-0021-0000-0000-000021BF62C6
Message-Id: <20190909185121.6271e9be@thinkpad>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-09_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1909090170
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2019 11:56:50 +0530
Anshuman Khandual <anshuman.khandual@arm.com> wrote:

[..]
> >=20
> > Hmm, I simply used this on my system to make pud_clear_tests() work, not
> > sure if it works on all archs:
> >=20
> > pud_val(*pudp) |=3D RANDOM_NZVALUE; =20
>=20
> Which compiles on arm64 but then fails on x86 because of the way pmd_val()
> has been defined there. on arm64 and s390 (with many others) pmd_val() is
> a macro which still got the variable that can be used as lvalue but that =
is
> not true for some other platforms like x86.
>=20
> arch/arm64/include/asm/pgtable-types.h:	#define pmd_val(x)	((x).pmd)
> arch/s390/include/asm/page.h:		#define pmd_val(x)	((x).pmd)
> arch/x86/include/asm/pgtable.h:		#define pmd_val(x)       native_pmd_val(=
x)
>=20
> static inline pmdval_t native_pmd_val(pmd_t pmd)
> {
>         return pmd.pmd;
> }
>=20
> Unless I am mistaken, the return value from this function can not be used=
 as
> lvalue for future assignments.
>=20
> mm/arch_pgtable_test.c: In function =E2=80=98pud_clear_tests=E2=80=99:
> mm/arch_pgtable_test.c:156:17: error: lvalue required as left operand of =
assignment
>   pud_val(*pudp) |=3D RANDOM_ORVALUE;
>                  ^~
> AFAICS pxx_val() were never intended to be used as lvalue and using it th=
at way
> might just happen to work on all those platforms which define them as mac=
ros.
> They meant to just provide values for an entry as being determined by the=
 platform.
>=20
> In principle pxx_val() on an entry was not supposed to be modified direct=
ly from
> generic code without going through (again) platform helpers for any speci=
fic state
> change (write, old, dirty, special, huge etc). The current use case is a =
deviation
> for that.
>=20
> I originally went with memset() just to load up the entries with non-zero=
 value so
> that we know pxx_clear() are really doing the clearing. The same is being=
 followed
> for all pxx_same() checks.
>=20
> Another way for fixing the problem would be to mark them with known attri=
butes
> like write/young/huge etc instead which for sure will create non-zero ent=
ries.
> We can do that for pxx_clear() and pxx_same() tests and drop RANDOM_NZVAL=
UE
> completely. Does that sound good ?

Umm, not really. Those mkwrite/young/huge etc. helpers do only exist for
page table levels where we can also have large mappings, at least on s390.
Also, we do (on s390) again check for certain sanity before actually setting
the bits.
Good news is that at least for the pxx_same() checks the memset() is no
problem, because pxx_same() does not do any checks other than the same chec=
k.

For the pxx_clear_tests(), maybe it could be an option to put them behind t=
he
pxx_populate_tests(), and rely on them having properly populated (non-clear)
values after that?

[...]
> >=20
> > Actually, using get_unmapped_area() as suggested by Kirill could also
> > solve this issue. We do create a new mm with 3-level page tables on s39=
0,
> > and the dynamic upgrade to 4 or 5 levels is then triggered exactly by
> > arch_get_unmapped_area(), depending on the addr. But I currently don't
> > see how / where arch_get_unmapped_area() is set up for such a dummy mm
> > created by mm_alloc(). =20
>=20
> Normally they are set during program loading but we can set it up explici=
tly
> for the test mm_struct if we need to but there are some other challenges.
>=20
> load_[aout|elf|flat|..]_binary()
> 	setup_new_exec()
> 		arch_pick_mmap_layout().
>=20
> I did some initial experiments around get_unmapped_area(). Seems bit tric=
ky
> to get it working on a pure 'test' mm_struct. It expects a real user cont=
ext
> in the form of current->mm.

Yes, that's where I stopped because it looked rather complicated :-)
Not sure why Kirill suggested it initially, but if using get_unmapped_area()
would only be necessary to get properly initialized page table levels
on s390, you could also defer this to a later add-on patch.

Regards,
Gerald


