Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB116B6F67
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 10:35:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so12742603plr.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 07:35:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s14sor21955601pgi.72.2018.12.04.07.35.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 07:35:54 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC v2 04/13] x86/mm: Add helper functions for MKTME memory encryption keys
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
Date: Tue, 4 Dec 2018 07:35:50 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <7896A3D4-22B3-4124-BA0A-ED763128C5D6@amacapital.net>
References: <cover.1543903910.git.alison.schofield@intel.com> <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, peterz@infradead.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org



> On Dec 3, 2018, at 11:39 PM, Alison Schofield <alison.schofield@intel.com>=
 wrote:
>=20
> Define a global mapping structure to manage the mapping of userspace
> Keys to hardware KeyIDs in MKTME (Multi-Key Total Memory Encryption).
> Implement helper functions that access this mapping structure.
>=20

Why is a key =E2=80=9Cvoid *=E2=80=9D?  Who owns the memory?  Can a real typ=
e be used?
