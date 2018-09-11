Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB00D8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 20:40:53 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m4-v6so11436009pgq.19
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:40:53 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y26-v6si8574273pgk.102.2018.09.10.17.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 17:40:52 -0700 (PDT)
From: "Huang, Kai" <kai.huang@intel.com>
Subject: RE: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
 Encryption API
Date: Tue, 11 Sep 2018 00:33:33 +0000
Message-ID: <105F7BF4D0229846AF094488D65A098935426D90@PGSMSX112.gar.corp.intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <b9c1e3805c700043d92117462bdb6018bb9f858a.1536356108.git.alison.schofield@intel.com>
 <105F7BF4D0229846AF094488D65A098935424996@PGSMSX112.gar.corp.intel.com>
 <20180911001301.GB31868@alison-desk.jf.intel.com>
In-Reply-To: <20180911001301.GB31868@alison-desk.jf.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Schofield, Alison" <alison.schofield@intel.com>
Cc: "dhowells@redhat.com" <dhowells@redhat.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Shutemov,
 Kirill" <kirill.shutemov@intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, "jmorris@namei.org" <jmorris@namei.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> Behalf Of Alison Schofield
> Sent: Tuesday, September 11, 2018 12:13 PM
> To: Huang, Kai <kai.huang@intel.com>
> Cc: dhowells@redhat.com; tglx@linutronix.de; Nakajima, Jun
> <jun.nakajima@intel.com>; Shutemov, Kirill <kirill.shutemov@intel.com>;
> Hansen, Dave <dave.hansen@intel.com>; Sakkinen, Jarkko
> <jarkko.sakkinen@intel.com>; jmorris@namei.org; keyrings@vger.kernel.org;
> linux-security-module@vger.kernel.org; mingo@redhat.com; hpa@zytor.com;
> x86@kernel.org; linux-mm@kvack.org
> Subject: Re: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
> Encryption API
>=20
> On Sun, Sep 09, 2018 at 06:28:28PM -0700, Huang, Kai wrote:
> >
> > > -----Original Message-----
> > > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
> > > Behalf Of Alison Schofield
> > > Sent: Saturday, September 8, 2018 10:34 AM
> > > To: dhowells@redhat.com; tglx@linutronix.de
> > > Cc: Huang, Kai <kai.huang@intel.com>; Nakajima, Jun
> > > <jun.nakajima@intel.com>; Shutemov, Kirill
> > > <kirill.shutemov@intel.com>; Hansen, Dave <dave.hansen@intel.com>;
> > > Sakkinen, Jarkko <jarkko.sakkinen@intel.com>; jmorris@namei.org;
> > > keyrings@vger.kernel.org; linux-security-module@vger.kernel.org;
> > > mingo@redhat.com; hpa@zytor.com; x86@kernel.org; linux-
> mm@kvack.org
> > > Subject: [RFC 01/12] docs/x86: Document the Multi-Key Total Memory
> > > Encryption API
> > >
> > > Document the API's used for MKTME on Intel platforms.
> > > MKTME: Multi-KEY Total Memory Encryption
> > >
> > > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > > ---
> > >  Documentation/x86/mktme-keys.txt | 153
> > > +++++++++++++++++++++++++++++++++++++++
> > >  1 file changed, 153 insertions(+)
> > >  create mode 100644 Documentation/x86/mktme-keys.txt
> > >
> > > diff --git a/Documentation/x86/mktme-keys.txt
> > > b/Documentation/x86/mktme- keys.txt new file mode 100644 index
> > > 000000000000..2dea7acd2a17
> > > --- /dev/null
> > > +++ b/Documentation/x86/mktme-keys.txt
> > > @@ -0,0 +1,153 @@
> > > +MKTME (Multi-Key Total Memory Encryption) is a technology that
> > > +allows memory encryption on Intel platforms. Whereas TME (Total
> > > +Memory
> > > +Encryption) allows encryption of the entire system memory using a
> > > +single key, MKTME allows multiple encryption domains, each having
> > > +their own key. The main use case for the feature is virtual machine
> > > +isolation. The API's introduced here are intended to offer
> > > +flexibility to work in a
> > > wide range of uses.
> > > +
> > > +The externally available Intel Architecture Spec:
> > > +https://software.intel.com/sites/default/files/managed/a5/16/Multi-
> > > +Key-
> > > +Total-Memory-Encryption-Spec.pdf
> > > +
> > > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D  API Overview
> > > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> > > +
> > > +There are 2 MKTME specific API's that enable userspace to create
> > > +and use the memory encryption keys:
> > > +
> > > +1) Kernel Key Service: MKTME Type
> > > +
> > > +   MKTME is a new key type added to the existing Kernel Key Services
> > > +   to support the memory encryption keys. The MKTME service manages
> > > +   the addition and removal of MKTME keys. It maps userspace keys
> > > +   to hardware keyids and programs the hardware with user requested
> > > +   encryption parameters.
> > > +
> > > +   o An understanding of the Kernel Key Service is required in order
> > > +     to use the MKTME key type as it is a subset of that service.
> > > +
> > > +   o MKTME keys are a limited resource. There is a single pool of
> > > +     MKTME keys for a system and that pool can be from 3 to 63 keys.
> >
> > Why 3 to 63 keys? Architecturally we are able to support up to 15-bit k=
eyID,
> although in the first generation server we only support 6-bit keyID, whic=
h is 63
> key/keyIDs (excluding keyID 0, which is TME's keyID).
>=20
> My understanding is that low level SKU's could have as few as 3 bits avai=
lable to
> hold the keyid, and that the max is 6 bits, hence 64.
> I probably don't need to be stating that level of detail here, but rather=
 just
> iterate the important point that the resource is limited!
>=20
> >
> > > +     With that in mind, userspace may take advantage of the kernel
> > > +     key services sharing and permissions model for userspace keys.
> > > +     One key can be shared as long as each user has the permission
> > > +     of "KEY_NEED_VIEW" to use it.
> > > +
> > > +   o MKTME key type uses capabilities to restrict the allocation
> > > +     of keys. It only requires CAP_SYS_RESOURCE, but will accept
> > > +     the broader capability of CAP_SYS_ADMIN.  See capabilities(7).
> > > +
> > > +   o The MKTME key service blocks kernel key service commands that
> > > +     could lead to reprogramming of in use keys, or loss of keys fro=
m
> > > +     the pool. This means MKTME does not allow a key to be invalidat=
ed,
> > > +     unlinked, or timed out. These operations are blocked by MKTME a=
s
> > > +     it creates all keys with the internal flag KEY_FLAG_KEEP.
> > > +
> > > +   o MKTME does not support the keyctl option of UPDATE. Userspace
> > > +     may change the programming of a key by revoking it and adding
> > > +     a new key with the updated encryption options (or vice-versa).
> > > +
> > > +2) System Call: encrypt_mprotect()
> > > +
> > > +   MKTME encryption is requested by calling encrypt_mprotect(). The
> > > +   caller passes the serial number to a previously allocated and
> > > +   programmed encryption key. That handle was created with the MKTME
> > > +   Key Service.
> > > +
> > > +   o The caller must have KEY_NEED_VIEW permission on the key
> > > +
> > > +   o The range of memory that is to be protected must be mapped as
> > > +     ANONYMOUS. If it is not, the entire encrypt_mprotect() request
> > > +     fails with EINVAL.
> > > +
> > > +   o As an extension to the existing mprotect() system call,
> > > +     encrypt_mprotect() supports the legacy mprotect behavior plus
> > > +     the enabling of memory encryption. That means that in addition
> > > +     to encrypting the memory, the protection flags will be updated
> > > +     as requested in the call.
> > > +
> > > +   o Additional mprotect() calls to memory already protected with
> > > +     MKTME will not alter the MKTME status.
> >
> > I think it's better to separate encrypt_mprotect() into another doc so =
both
> parts can be reviewed easier.
>=20
> I can do that.
> Also, I do know I need man page for that too.
> >
> > > +
> > > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D  =
Usage: MKTME Key Service
> > > +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > +
> > > +MKTME is enabled on supported Intel platforms by selecting
> > > +CONFIG_X86_INTEL_MKTME which selects CONFIG_MKTME_KEYS.
> > > +
> > > +Allocating MKTME Keys via command line or system call:
> > > +    keyctl add mktme name "[options]" ring
> > > +
> > > +    key_serial_t add_key(const char *type, const char *description,
> > > +                         const void *payload, size_t plen,
> > > +                         key_serial_t keyring);
> > > +
> > > +Revoking MKTME Keys via command line or system call::
> > > +   keyctl revoke <key>
> > > +
> > > +   long keyctl(KEYCTL_REVOKE, key_serial_t key);
> > > +
> > > +Options Field Definition:
> > > +    userkey=3D      ASCII HEX value encryption key. Defaults to a CP=
U
> > > +		  generated key if a userkey is not defined here.
> > > +
> > > +    algorithm=3D    Encryption algorithm name as a string.
> > > +		  Valid algorithm: "aes-xts-128"
> > > +
> > > +    tweak=3D        ASCII HEX value tweak key. Tweak key will be add=
ed to the
> > > +                  userkey...  (need to be clear here that this is be=
ing sent
> > > +                  to the hardware - kernel not messing w it)
> > > +
> > > +    entropy=3D      ascii hex value entropy.
> > > +                  This entropy will be used to generated the CPU key=
 and
> > > +		  the tweak key when CPU generated key is requested.
> > > +
> > > +Algorithm Dependencies:
> > > +    AES-XTS 128 is the only supported algorithm.
> > > +    There are only 2 ways that AES-XTS 128 may be used:
> > > +
> > > +    1) User specified encryption key
> > > +	- The user specified encryption key must be exactly
> > > +	  16 ASCII Hex bytes (128 bits).
> > > +	- A tweak key must be specified and it must be exactly
> > > +	  16 ASCII Hex bytes (128 bits).
> > > +	- No entropy field is accepted.
> > > +
> > > +    2) CPU generated encryption key
> > > +	- When no user specified encryption key is provided, the
> > > +	  default encryption key will be CPU generated.
> > > +	- User must specify 16 ASCII Hex bytes of entropy. This
> > > +	  entropy will be used by the CPU to generate both the
> > > +	  encryption key and the tweak key.
> > > +	- No entropy field is accepted.
>              ^^^^^^^ should be tweak
>=20
> >
> > This is not true. The spec says in CPU generated random mode, both 'key=
' and
> 'tweak' part are used to generate the final key and tweak respectively.
> >
> > Actually, simple 'XOR' is used to generate the final key:
> >
> > case KEYID_SET_KEY_RANDOM:
> > 	......
> > 	(* Mix user supplied entropy to the data key and tweak key *)
> > 	TMP_RND_DATA_KEY =3D TMP_RND_KEY XOR
> > 		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_1.BYTES[15:0];
> > 	TMP_RND_TWEAK_KEY =3D TMP_RND_TWEAK_KEY XOR
> > 		TMP_KEY_PROGRAM_STRUCT.KEY_FIELD_2.BYTES[15:0];
> >
> > So I think we can either just remove 'entropy' parameter, since we can =
use
> both 'userkey' and 'tweak' even for random key mode.
> >
> > In fact, which might be better IMHO, we can simply disallow or ignore
> 'userkey' and 'tweak' part for random key mode, since if we allow user to=
 specify
> both entropies, and if user passes value with all 1, we are effectively m=
aking the
> key and tweak to be all 1, which is not random anymore.
> >
> > Instead, kernel can generate random for both entropies, or we can simpl=
y uses
> 0, ignoring user input.
>=20
> Kai,
> I think my typo above, threw you off. We have the same understanding of t=
he
> key fields.
>=20
> Is this the structure you are suggesting?
>=20
> 	Options
>=20
> 	key_type=3D	"user" or "CPU"
>=20
> 	key=3D		If key_type =3D=3D user
> 				key=3D is the data key
> 			If key_type =3D=3D CPU
> 				key=3D is not required
> 				if key=3D is present
> 					it is entropy to be mixed with
> 					CPU generated data key
>=20
> 	tweak=3D		If key_type =3D=3D user
> 				tweak=3D is the tweak key
> 			If key_type =3D=3D CPU
> 				tweak=3D is not required
> 				if tweak=3D is present
> 					it is entropy to be mixed with
> 					CPU generated tweak key

Exactly.

Although I am not sure whether we should support other 2 modes: Clear key  =
and  no encryption;

Thanks,
-Kai
>=20
>=20
> Alison
> >
> > Thanks,
> > -Kai
>=20
> ........snip...........
