From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
Date: Mon, 28 Jan 2019 08:34:56 -0800
Message-ID: <CAPcyv4j2vmWXQO0QoBU5-yXBJBaEuDrPJ0t1tWkftCbwb4rnWA@mail.gmail.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com> <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
 <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
 <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
 <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com>
 <dc7d8190-2c94-9bdb-fb5b-a80a3fb55822@oracle.com> <CAPcyv4hEyG-1hC=20M7YGFG-BF7yvNcG7EkLurAfysHHB2yXBA@mail.gmail.com>
 <20190128092549.GF18811@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190128092549.GF18811@dhcp22.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Michal Hocko <mhocko@kernel.org>
Cc: Jane Chu <jane.chu@oracle.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Du, Fan" <fan.du@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de" <tiwai@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, "zwisler@kernel.org" <zwisler@kernel.org>, "baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Huang, Ying" <ying.huang@intel.com>, "bhelgaas@google.com" <bhelgaas@g>
List-Id: linux-mm.kvack.org

On Mon, Jan 28, 2019 at 1:26 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 25-01-19 11:15:08, Dan Williams wrote:
> [...]
> > However, we should consider this along with the userspace enabling to
> > control which device-dax instances are set aside for hotplug. It would
> > make sense to have a "clear errors before hotplug" configuration
> > option.
>
> I am not sure I understand. Do you mean to clear HWPoison when the
> memory is hotadded (add_pages) or onlined (resp. move_pfn_range_to_zone)?

Before the memory is hot-added via the kmem driver it shows up as an
independent persistent memory namespace. A namespace can be configured
as a block device and errors cleared by writing to the given "bad
block". Once all media errors are cleared the namespace can be
assigned as volatile memory to the core-kernel mm. The memory range
starts as a namespace each boot and must be hotplugged via startup
scripts, those scripts can be made to handle the bad block pruning.
