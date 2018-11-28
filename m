Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: =?utf-8?Q?Re=3A_=5BPATCH_0/2=5D_Don=E2=80=99t_leave_executable_TL?=
 =?utf-8?Q?B_entries_to_freed_pages?=
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
Date: Tue, 27 Nov 2018 17:06:05 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <CDB8B7C1-FD55-44AD-9B71-B3A750BF5489@gmail.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com, kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com
List-ID: <linux-mm.kvack.org>

> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe =
<rick.p.edgecombe@intel.com> wrote:
>=20
> Sometimes when memory is freed via the module subsystem, an executable
> permissioned TLB entry can remain to a freed page. If the page is =
re-used to
> back an address that will receive data from userspace, it can result =
in user
> data being mapped as executable in the kernel. The root of this =
behavior is
> vfree lazily flushing the TLB, but not lazily freeing the underlying =
pages.=20
>=20
> There are sort of three categories of this which show up across =
modules, bpf,
> kprobes and ftrace:
>=20
> 1. When executable memory is touched and then immediatly freed
>=20
>   This shows up in a couple error conditions in the module loader and =
BPF JIT
>   compiler.

Interesting!

Note that this may cause conflict with "x86: avoid W^X being broken =
during
modules loading=E2=80=9D, which I recently submitted.
