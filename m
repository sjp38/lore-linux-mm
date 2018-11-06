Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 512746B049F
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:51:20 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id i17-v6so13536016wre.5
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:51:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d70-v6sor2184235wme.3.2018.11.06.14.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 14:51:18 -0800 (PST)
MIME-Version: 1.0
References: <20181106222009.90833-1-marcorr@google.com> <20181106222009.90833-3-marcorr@google.com>
 <ff90f374-caea-9530-0c90-b27d00efacc1@intel.com>
In-Reply-To: <ff90f374-caea-9530-0c90-b27d00efacc1@intel.com>
From: Marc Orr <marcorr@google.com>
Date: Tue, 6 Nov 2018 14:51:06 -0800
Message-ID: <CAA03e5EWFPayGQskjBAyj++LNfWrPXhh3-CvOorGc03FMUYy0g@mail.gmail.com>
Subject: Re: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
Content-Type: multipart/alternative; boundary="000000000000f08d35057a06d67d"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, Wanpeng Li <kernellwp@gmail.com>

--000000000000f08d35057a06d67d
Content-Type: text/plain; charset="UTF-8"

On Tue, Nov 6, 2018 at 2:49 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 11/6/18 2:20 PM, Marc Orr wrote:
> >       r = -ENOMEM;
> > +     x86_fpu_cache = kmem_cache_create_usercopy(
> > +                             "x86_fpu",
> > +                             fpu_kernel_xstate_size,
> > +                             __alignof__(struct fpu),
> > +                             SLAB_ACCOUNT,
> > +                             offsetof(struct fpu, state),
> > +                             fpu_kernel_xstate_size,
> > +                             NULL);
>
> I thought we came to the conclusion with Paulo that this should not be
> "usercopy" at all.
>
> Did you send out an old version?
>

Oops. Yes, I sent the old version. Re-sending now.

--000000000000f08d35057a06d67d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGJyPjxicj48ZGl2IGNsYXNzPSJnbWFpbF9xdW90ZSI+PGRpdiBkaXI9
Imx0ciI+T24gVHVlLCBOb3YgNiwgMjAxOCBhdCAyOjQ5IFBNIERhdmUgSGFuc2VuICZsdDs8YSBo
cmVmPSJtYWlsdG86ZGF2ZS5oYW5zZW5AaW50ZWwuY29tIj5kYXZlLmhhbnNlbkBpbnRlbC5jb208
L2E+Jmd0OyB3cm90ZTo8YnI+PC9kaXY+PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBz
dHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGlu
Zy1sZWZ0OjFleCI+T24gMTEvNi8xOCAyOjIwIFBNLCBNYXJjIE9yciB3cm90ZTo8YnI+DQomZ3Q7
wqAgwqAgwqAgwqByID0gLUVOT01FTTs8YnI+DQomZ3Q7ICvCoCDCoCDCoHg4Nl9mcHVfY2FjaGUg
PSBrbWVtX2NhY2hlX2NyZWF0ZV91c2VyY29weSg8YnI+DQomZ3Q7ICvCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCZxdW90O3g4Nl9mcHUmcXVvdDssPGJyPg0KJmd0
OyArwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBmcHVfa2VybmVs
X3hzdGF0ZV9zaXplLDxicj4NCiZndDsgK8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgX19hbGlnbm9mX18oc3RydWN0IGZwdSksPGJyPg0KJmd0OyArwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBTTEFCX0FDQ09VTlQsPGJyPg0KJmd0
OyArwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBvZmZzZXRvZihz
dHJ1Y3QgZnB1LCBzdGF0ZSksPGJyPg0KJmd0OyArwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqBmcHVfa2VybmVsX3hzdGF0ZV9zaXplLDxicj4NCiZndDsgK8KgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgTlVMTCk7PGJyPg0KPGJyPg0K
SSB0aG91Z2h0IHdlIGNhbWUgdG8gdGhlIGNvbmNsdXNpb24gd2l0aCBQYXVsbyB0aGF0IHRoaXMg
c2hvdWxkIG5vdCBiZTxicj4NCiZxdW90O3VzZXJjb3B5JnF1b3Q7IGF0IGFsbC48YnI+DQo8YnI+
DQpEaWQgeW91IHNlbmQgb3V0IGFuIG9sZCB2ZXJzaW9uPzxicj48L2Jsb2NrcXVvdGU+PGRpdj48
YnI+PC9kaXY+PGRpdj5Pb3BzLiBZZXMsIEkgc2VudCB0aGUgb2xkIHZlcnNpb24uIFJlLXNlbmRp
bmcgbm93LjwvZGl2PjwvZGl2PjwvZGl2Pg0K
--000000000000f08d35057a06d67d--
